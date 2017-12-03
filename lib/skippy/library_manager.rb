require 'git'
require 'json'
require 'naturally'
require 'pathname'

require 'skippy/helpers/file'
require 'skippy/lib_source'
require 'skippy/library'
require 'skippy/project'

class Skippy::LibraryManager

  include Enumerable
  include Skippy::Helpers::File

  attr_reader :project

  # @param [Skippy::Project] project
  def initialize(project)
    raise TypeError, 'expected a Project' unless project.is_a?(Skippy::Project)
    @project = project
  end

  # @yield [Skippy::Library]
  def each
    directories(path).each { |lib_path|
      yield Skippy::Library.new(lib_path)
    }
    self
  end

  def empty?
    to_a.empty?
  end

  # @param [String] module_name
  # @return [Skippy::LibModule, nil]
  def find_module(module_name)
    library_name, module_name = module_name.split('/')
    if library_name.nil? || module_name.nil?
      raise ArgumentError, 'expected a module path'
    end
    library = find { |lib| lib.name == library_name }
    return nil if library.nil?
    library.modules.find { |mod| mod.basename == module_name }
  end

  # @raise [Skippy::LibModule::ModuleNotFoundError]
  # @param [String] module_name
  # @return [Skippy::LibModule]
  def find_module_or_fail(module_name)
    lib_module = find_module(module_name)
    if lib_module.nil?
      raise Skippy::LibModule::ModuleNotFoundError,
        "module '#{module_name}' not found"
    end
    lib_module
  end

  # @param [Pathname, String] source
  def install(source, options = {})
    raise Skippy::Project::ProjectNotSavedError unless project.exist?
    sources = project.config.get(:sources, []) # TODO: Move to Project
    lib_source = Skippy::LibrarySource.new(source.to_s, sources)
    # TODO: Check if library already exist.
    #       Update as needed.
    if lib_source.local?
      library = install_from_local(source)
    elsif lib_source.git?
      # library = install_from_git(source. options)
      library = install_from_git(lib_source)
    else
      # TODO: Review error type.
      raise Skippy::Error, "Unable to handle source: #{source}"
    end

    # TODO: Check for existing entry.
    project.config.push(:libraries,
      name: library.name,
      version: library.version,
      source: lib_source.origin)

    project.save

    library
  end

  # @return [Integer]
  def length
    to_a.length
  end
  alias size length

  # @return [Pathname]
  def path
    project.path('.skippy/libs')
  end

  private

  def install_from_local(source)
    library = Skippy::Library.new(source)
    target = path.join(library.name)
    FileUtils.mkdir_p(path)
    FileUtils.copy_entry(source, target)
    Skippy::Library.new(target)
  end

  # @param [Skippy::LibrarySource] source
  # @param [String] version 'edge', 'latest' or a tag (E.g.: '1.2.3')
  # @param [String] branch
  def install_from_git(source, version: 'latest', branch: nil)
    puts "Installing #{source.basename} from #{source.origin}..."
    target = path.join(source.lib_path)
    puts "> Target: #{target}"
    # Clone the repository into the project's library path:
    if target.directory?
      puts '> Updating...'
      git = Git.open(target)
      git.reset_hard
      git.pull
    else
      puts '> Cloning...'
      git = Git.clone(source.origin, source.lib_path, path: path)
    end
    # Check out given branch - otherwise rely fall back on default branch.
    if branch
      branches = git.braches.map(&:name)
      puts "> Branches: #{branches.inspect}"
      unless branches.include?(branch)
        # TODO: Review error type.
        raise Skippy::Error, "Unable to checkout branch: '#{branch}'"
      end
      git.checkout(branch)
    end
    # Check out given version - otherwise fall back to latest version.
    unless edge_version?(version)
      tags = Naturally.sort(git.tags.map(&:name))
      # TODO: Might be no tags.
      puts "> Tags: #{tags.inspect}"
      tag = latest_version?(version) ? tags.last : resolve_tag(tags, version)
      if tag.nil?
        # TODO: Review error type.
        raise Skippy::Error, "Unable to checkout version: '#{version}'"
      end
      git.checkout(tag)
    end
    # Return a library object representing the cloned git source.
    # target = path.join(source.lib_path)
    library = Skippy::Library.new(target)
    # TODO: Verify this is a Skippy library.
    # TODO: Verify library version.
    library
  end

  def edge_version?(version)
    version.casecmp('edge').zero?
  end

  def latest_version?(version)
    version.casecmp('latest').zero?
  end

  def resolve_tag(tags, version)
    # TODO: Resolve version numbers like RubyGem.
    tags.find { |tag| tag.name == version }
  end

end
