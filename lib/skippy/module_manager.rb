
require 'fileutils'
require 'json'
require 'pathname'

require 'skippy/helpers/file'
require 'skippy/lib_module'
require 'skippy/project'

class Skippy::ModuleManager

  include Enumerable
  include Skippy::Helpers::File

  attr_reader :project

  # @param [Skippy::Project] project
  def initialize(project)
    raise TypeError, 'expected a Project' unless project.is_a?(Skippy::Project)
    @project = project
  end

  # @yield [Skippy::LibModule]
  def each
    directories(path).each { |library_path|
      library_path.each_child { |module_file|
        next unless module_file.file?
        next unless module_file.extname == '.rb' # TODO: .casecmp
        yield Skippy::LibModule.new(module_file)
      }
    }
    self
  end

  def empty?
    to_a.empty?
  end

  # @param [String] module_name
  # @return [Skippy::LibModule, nil]
  def find_module(module_name)
    find { |lib_module| lib_module.name == module_name }
  end

  # @param [Skippy::LibModule, String] lib_module
  def installed?(lib_module)
    module_name = lib_module.name
    project = Skippy::Project.current
    modules = project && project.config.get(:modules, [])
    modules.any? { |mod| mod == module_name }
  end

  # @param [String] module_name
  # @return [Skippy::LibModule]
  def use(module_name)
    raise Skippy::Project::ProjectNotSavedError unless project.exist?

    lib_module = project.libraries.find_module_or_fail(module_name)

    source = lib_module.path
    target = path.join(lib_module.library.name, lib_module.path.basename)

    copy_module(lib_module, source, target)

    project.config.push(:modules, lib_module.name)

    project.save

    lib_module
  end

  # @return [Integer]
  def length
    to_a.length
  end
  alias size length

  # @return [Pathname]
  def path
    project.path.join('src', project.namespace.to_underscore, 'vendor')
  end

  private

  # @param [Skippy::LibModule] lib_module
  # @param [Pathname, String] source
  # @param [Pathname, String] target
  def copy_module(lib_module, source, target)
    # Copy the main library file.
    copy_file(lib_module, source, target)
    # Copy optional support folder.
    basename = source.basename('.*')
    source_support_folder = source.parent.join(basename)
    return unless source_support_folder.directory?
    target_support_folder = target.parent.join(basename)
    copy_directory(lib_module, source_support_folder, target_support_folder)
  end

  # @param [Skippy::LibModule] lib_module
  # @param [Pathname, String] source
  # @param [Pathname, String] target
  def copy_directory(lib_module, source_path, target_path)
    Dir.glob("#{source_path}/**/*") { |filename|
      source = Pathname.new(filename)
      next unless source.file?
      relative_path = source.relative_path_from(source_path)
      target = target_path.join(relative_path)
      copy_file(lib_module, source, target)
    }
  end

  # @param [Skippy::LibModule] lib_module
  # @param [Pathname, String] source
  # @param [Pathname, String] target
  def copy_file(lib_module, source, target)
    FileUtils.mkdir_p(target.parent)
    if source.extname.casecmp('.rb').zero?
      content = File.read(source)
      transform_require(lib_module, content)
      transform_module(content)
      File.write(target, content)
    else
      File.copy(source, target)
    end
  end

  # Transform the module content with `SkippyLib` placeholder replaced with
  # the project namespace.
  #
  # @param [String] content
  # @return [String]
  def transform_module(content)
    content.gsub!('SkippyLib', project.namespace)
    content
  end

  LIB_REQUIRE_PATTERN = /(\brequire ["'])(modules)(\/[^"']*["'])/.freeze

  # Transform the require statements to the target destination.
  #
  # @param [Skippy::LibModule] lib_module
  # @param [String] content
  # @return [String]
  def transform_require(lib_module, content)
    extension_source = project.path.join('src') # TODO: Move to Project
    relative_path = path.relative_path_from(extension_source)
    target_path = relative_path.join(lib_module.library.name)
    content.gsub!(LIB_REQUIRE_PATTERN, "\\1#{target_path}\\3")
    content
  end

end
