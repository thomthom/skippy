require 'git'
require 'json'
require 'naturally'
require 'pathname'

require 'skippy/helpers/file'
require 'skippy/error'
require 'skippy/lib_source'
require 'skippy/library'
require 'skippy/project'

module Skippy

  class BranchNotFound < Skippy::Error; end
  class TagNotFound < Skippy::Error; end
  class UnknownSourceType < Skippy::Error; end

end

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
    lib_source = Skippy::LibrarySource.new(source.to_s, project.sources)
    if lib_source.local?
      library = install_from_local(source)
    elsif lib_source.git?
      library = install_from_git(lib_source, options)
    else
      raise Skippy::UnknownSourceType, "Unable to handle source: #{source}"
    end

    # TODO: Make lib_source, part of library?
    update_library_config(library, lib_source)
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

  def update_library_config(library, lib_source)
    # TODO: version should be the requested version pattern.
    data = {
      name: library.name,
      version: library.version,
      source: lib_source.origin,
    }
    libraries = project.config.get(:libraries, [])
    existing = libraries.find { |lib| lib[:name].casecmp(library.name).zero? }
    if existing
      existing.clear
      existing.merge!(data)
    else
      project.config.push(:libraries, data)
    end
    nil
  end

  # @param [Pathname, String] source
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
    # TODO: Convert this into it's own GitInstaller class.
    #       This class should accept a callback for yielding installation status
    #       which the Thor layer can utilise - avoiding this class from
    #       outputting directly.
    puts "Installing #{source.basename} from #{source.origin}..."
    target = path.join(source.lib_path)
    puts "> Target: #{target}"
    # Clone the repository into the project's library path:
    if target.directory?
      puts '> Updating...'
      library = Skippy::Library.new(target)
      puts "> Current version: #{library.version}"
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
        # TODO: Revert to previously checked out commit.
        raise Skippy::BranchNotFound, "Found no branch named: '#{branch}'"
      end
      git.checkout(branch)
    end
    # Check out given version - otherwise fall back to latest version.
    unless edge_version?(version)
      tags = Naturally.sort_by(git.tags, :name)
      # TODO: Might be no tags.
      puts "> Tags: #{tags.map(&:name).inspect}"
      tag = latest_version?(version) ? tags.last : resolve_tag(tags, version)
      if tag.nil?
        # TODO: Revert to previously checked out commit.
        raise Skippy::TagNotFound, "Found no version: '#{version}'"
      end
      git.checkout(tag)
      # Verify the library version with the tagged version.
      library = Skippy::Library.new(target)
      unless library.version.casecmp(tag.name).zero?
        warn "skippy.json version (#{library.version}) differ from tagged version #{tag.name}"
      end
    end
    # Return a library object representing the cloned git source.
    library = Skippy::Library.new(target)
    library
  end

  # @param [String] version
  def edge_version?(version)
    version.casecmp('edge').zero?
  end

  # @param [String] version
  def latest_version?(version)
    version.casecmp('latest').zero?
  end

  # Resolve version numbers like RubyGem.
  #
  # @param [Array<Git::Tag>] tags List of tags sorted with newest first
  # @param [String] version
  # @return [Git::Tag]
  def resolve_tag(tags, version)
    requirement = Gem::Requirement.new(version)
    tags.reverse.find { |tag|
      next false unless Gem::Version.correct?(tag.name)
      tag_version = Gem::Version.new(tag.name)
      requirement.satisfied_by?(tag_version)
    }
  end

end
