# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'pathname'
require 'set'

require 'skippy/helpers/file'
require 'skippy/lib_module'
require 'skippy/project'
require 'skippy/sorted_set'

class Skippy::ModuleManager

  include Enumerable
  include Skippy::Helpers::File

  attr_reader :project

  # @param [Skippy::Project] project
  def initialize(project)
    raise TypeError, 'expected a Project' unless project.is_a?(Skippy::Project)

    @project = project
    @modules = SortedSet.new(discover_modules)
  end

  # @yield [Skippy::LibModule]
  def each(&block)
    @modules.each(&block)
    self
  end

  def empty?
    to_a.empty?
  end

  # @param [String] module_name
  # @return [Skippy::LibModule, nil]
  def find_module(module_name)
    find { |lib_module| lib_module.name.casecmp(module_name).zero? }
  end

  # @param [Skippy::LibModule, String] lib_module
  def installed?(lib_module)
    module_name = lib_module.name
    modules = project&.config&.get(:modules, [])
    modules.any? { |mod| mod.casecmp(module_name).zero? }
  end

  # @param [String] module_name
  # @return [Skippy::LibModule]
  def use(module_name)
    raise Skippy::Project::ProjectNotSavedError unless project.exist?

    lib_module = project.libraries.find_module_or_fail(module_name)

    source = lib_module.path
    target = vendor_path.join(lib_module.library.name, lib_module.path.basename)

    copy_module(lib_module, source, target)
    @modules << lib_module

    lib_module
  end

  # @param [Skippy::Library]
  # @return [Array<Skippy::LibModule>]
  def update(library)
    raise Skippy::Project::ProjectNotSavedError unless project.exist?

    installed = select { |mod| mod.library.name.casecmp(library.name).zero? }
    installed.each { |mod| use(mod.name) }
    installed
  end

  # @param [String] module_name
  # @return [Skippy::LibModule]
  def remove(module_name)
    raise Skippy::Project::ProjectNotSavedError unless project.exist?

    lib_module = project.libraries.find_module_or_fail(module_name)

    target = vendor_path.join(lib_module.library.name, lib_module.path.basename)
    support = vendor_path.join(lib_module.library.name, lib_module.basename)
    target.delete if target.exist?
    support.rmtree if support.directory?

    @modules.delete_if { |mod| mod.name.casecmp(lib_module.name).zero? }

    lib_module
  end

  # @return [Integer]
  def length
    to_a.length
  end
  alias size length

  # @return [Pathname]
  def vendor_path
    project.extension_source.join(project.basename, 'vendor')
  end

  private

  # @return [Array<Skippy::LibModule>]
  def discover_modules
    modules = []
    project.libraries.each { |library|
      library_vendor_path = vendor_path.join(library.name)
      next unless library_vendor_path.directory?

      library_vendor_path.each_child { |module_file|
        next unless module_file.file?
        next unless module_file.extname.casecmp('.rb').zero?

        modules << Skippy::LibModule.new(library, module_file)
      }
    }
    modules
  end

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
      FileUtils.copy(source, target)
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

  LIB_REQUIRE_PATTERN = %r{(\brequire ["'])(modules)(/[^"']*["'])}.freeze

  # Transform the require statements to the target destination.
  #
  # @param [Skippy::LibModule] lib_module
  # @param [String] content
  # @return [String]
  def transform_require(lib_module, content)
    relative_path = vendor_path.relative_path_from(project.extension_source)
    target_path = relative_path.join(lib_module.library.name)
    content.gsub!(LIB_REQUIRE_PATTERN, "\\1#{target_path}\\3")
    content
  end

end
