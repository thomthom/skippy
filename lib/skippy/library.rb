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

  attr_reader :path

  config_attr_reader :title, key: :name # TODO(thomthom): Clean up this kludge.
  config_attr_reader :name
  config_attr_reader :version

  class LibraryNotFoundError < Skippy::Error; end

  def initialize(path)
    @path = Pathname.new(path)
    raise LibraryNotFoundError, @path.to_s unless @path.directory?
    # noinspection RubyResolve
    @config = Skippy::Config.load(config_file)
  end

  def modules
    # .rb files in the library's modules_path are considered modules.
    libs = modules_path.children(false).select { |file|
      file.extname.casecmp('.rb').zero?
    }
    libs.map! { |lib|
      path = modules_path.join(lib)
      Skippy::LibModule.new(path)
    }
    libs
  end

  def to_s
    name
  end

  private

  def config_file
    path.join(CONFIG_FILENAME)
  end

  def modules_path
    path.join('modules')
  end

end
