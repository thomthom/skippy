require 'git'
require 'json'
require 'naturally'
require 'pathname'
require 'set'

require 'skippy/helpers/file'
require 'skippy/installer/git'
require 'skippy/installer/local'
require 'skippy/error'
require 'skippy/lib_source'
require 'skippy/library'
require 'skippy/project'

module Skippy

  class LibraryNotFound < Skippy::Error; end
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
    @libraries = SortedSet.new(discover_libraries)
  end

  # @yield [Skippy::Library]
  def each
    @libraries.each { |library| yield library }
    self
  end

  def empty?
    to_a.empty?
  end

  # @param [String] library_name
  # @return [Skippy::LibModule, nil]
  def find_library(library_name)
    find { |lib| lib.name == library_name }
  end

  # @param [String] module_name
  # @return [Skippy::LibModule, nil]
  def find_module(module_name)
    library_name, module_name = module_name.split('/')
    if library_name.nil? || module_name.nil?
      raise ArgumentError, 'expected a module path'
    end
    library = find_library(library_name)
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
  # @return [Skippy::Library]
  def install(source, options = {})
    raise Skippy::Project::ProjectNotSavedError unless project.exist?
    lib_source = Skippy::LibrarySource.new(project, source, options)

    installer = get_installer(lib_source)
    if block_given?
      installer.on_status { |type, message|
        yield type, message
      }
    end
    library = installer.install

    @libraries.delete(library)
    @libraries << library

    project.modules.update(library)

    library
  end

  # @param [Skippy::Library, String] source
  # @return [Skippy::Library]
  def uninstall(lib)
    raise Skippy::Project::ProjectNotSavedError unless project.exist?
    library = lib.is_a?(Skippy::Library) ? lib : find_library(lib)
    raise Skippy::LibraryNotFound, 'Library not found' if library.nil?
    # Uninstall modules first - using the module manager.
    vendor_module_path = project.modules.path.join(library.name)
    library.modules.each { |mod|
      project.modules.remove(mod.name)
    }
    vendor_module_path.rmtree
    raise 'Unable to remove vendor modules' if vendor_module_path.exist?
    # How the library itself is safe to remove.
    library.path.rmtree
    raise 'Unable to remove library' if library.path.exist?
    @libraries.delete(library)
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

  # @return [Array<Skippy::Library>]
  def discover_libraries
    project.config.get(:libraries, []).map { |lib_config|
      Skippy::Library.from_config(project, lib_config)
    }
  end

  # @param [Skippy::LibrarySource] lib_source
  # @return [Skippy::Installer]
  def get_installer(lib_source)
    if lib_source.git?
      Skippy::GitLibraryInstaller.new(project, lib_source)
    elsif lib_source.local?
      Skippy::LocalLibraryInstaller.new(project, lib_source)
    else
      raise Skippy::UnknownSourceType, "Unable to handle source: #{source}"
    end
  end

end
