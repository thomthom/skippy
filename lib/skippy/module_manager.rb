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
        next unless module_file.extname == '.rb'
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
    module_name = lib_module.is_a?(Skippy::LibModule) ? lib_module.name : lib_module
    project = Skippy::Project.current
    project && project.config.get(:modules, []).any? { |mod| mod == module_name }
  end

  # @param [String] module_name
  # @return [Skippy::LibModule]
  def use(module_name)
    raise Skippy::Project::ProjectNotSavedError unless project.exist?

    lib_module = project.libraries.find_module(module_name)
    raise Skippy::LibModule::ModuleNotFoundError,
          "module '#{module_name}' not found" if lib_module.nil?

    source = lib_module.path
    target = path.join(lib_module.library.name, lib_module.path.basename)

    copy_module(source, target)

    project.config.push(:modules, lib_module.to_s)

    project.save

    lib_module
  end

  # @return [Integer]
  def length
    to_a.length
  end
  alias :size :length

  # @return [Pathname]
  def path
    project.path.join('src', project.namespace.to_underscore, 'vendor')
  end

  private

  # @param [Pathname, String] source
  # @param [Pathname, String] target
  def copy_module(source, target)
    FileUtils.mkdir_p(target.parent)
    content = File.read(source)
    transform_module(content)
    File.write(target, content)
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

end
