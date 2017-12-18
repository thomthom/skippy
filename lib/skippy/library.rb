require 'json'
require 'pathname'

require 'skippy/helpers/file'
require 'skippy/config'
require 'skippy/config_accessors'
require 'skippy/lib_module'

class Skippy::Library

  extend Skippy::ConfigAccessors

  include Skippy::Helpers::File

  CONFIG_FILENAME = 'skippy.json'.freeze

  attr_reader :path, :source, :requirement

  config_attr_reader :title, key: :name # TODO(thomthom): Clean up this kludge.
  config_attr_reader :name
  config_attr_reader :version

  class LibraryNotFoundError < Skippy::Error; end

  # @param [Skippy::Project] project
  # @param [Hash] library
  # @return [Skippy::Library]
  def self.from_config(project, library)
    # TODO: Cannot refer to project.library.path here. Clean up how path is
    #       obtained.
    # path = project.libraries.path.join(library[:name])
    # path = project.path('.skippy/libs').join(library[:name])
    options = {}
    options[:requirement] = library[:requirement] if library[:requirement]
    source = Skippy::LibrarySource.new(project, library[:source], options)
    # new(path, source: source)
    # TODO: Clean up kludge.
    libraries_path = project.path('.skippy/libs')
    path = Skippy::Helpers::File.directories(libraries_path).find { |directory|
      new(directory, source: source).name.casecmp(library[:name]).zero?
    }
    new(path, source: source)
  end

  # @param [Pathname, String] path
  # @param [Skippy::LibrarySource] source
  def initialize(path, source: nil)
    # TODO: Rename LibrarySource - it also contain requirement.
    @path = Pathname.new(path)
    raise LibraryNotFoundError, @path.to_s unless @path.directory?
    raise LibraryNotFoundError, config_file.to_s unless config_file.exist?
    @config = Skippy::Config.load(config_file)
    @source = source
  end

  def <=>(other)
    # TODO: This isn't taking into account version. Maybe take that into account
    #       and implement Comparable.
    other.is_a?(self.class) ? name <=> other.name : nil
  end

  def eql?(other)
    # http://javieracero.com/blog/the-key-to-ruby-hashes-is-eql-hash
    # TODO: Compare using #hash.
    other.is_a?(self.class) && name.casecmp(other.name).zero?
  end

  def hash
    # TODO: This doesn't take into account version. Right now LibraryManager
    #        relies on this to avoid listing the same lib multiple times.
    #        But maybe this hash should reflect version differences and the
    #        library manager enforce library uniqueness differently.
    name.hash
  end

  # @return [Array<Skippy::LibModule>]
  def modules
    # .rb files in the library's modules_path are considered modules.
    libs = modules_path.children(false).select { |file|
      file.extname.casecmp('.rb').zero?
    }
    libs.map! { |lib|
      path = modules_path.join(lib)
      Skippy::LibModule.new(self, path)
    }
    libs
  end

  # @return [Hash]
  def to_h
    hash = {
      name: name, # TODO: Could be issue as UUID if name changes...
      version: version,
      source: source.origin,
    }
    hash[:requirement] = source.requirement unless source.requirement.nil?
    hash
  end

  # @return [String]
  def to_s
    name
  end

  private

  # @return [Pathname]
  def config_file
    path.join(CONFIG_FILENAME)
  end

  # @return [Pathname]
  def modules_path
    path.join('modules')
  end

end
