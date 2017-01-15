require 'json'
require 'pathname'

require 'skippy/helpers/file'
require 'skippy/lib_module'

class Skippy::Library

  include Skippy::Helpers::File

  CONFIG_FILENAME = 'skippy.json'.freeze

  attr_reader :path

  class LibraryNotFoundError < RuntimeError; end

  def initialize(path)
    @path = Pathname.new(path)
    raise LibraryNotFoundError, @path.to_s unless @path.exist?
    @config = load_library_config
  end

  def name
    path.basename.to_s
  end

  def title
    @config[:name]
  end

  def version
    @config[:version]
  end

  def modules
    libs = modules_path.children(false).select { |file|
      file.extname.downcase == '.rb'
    }
    libs.map! { |lib|
      path = modules_path.join(lib)
      Skippy::LibModule.new(path)
    }
    libs
  end

  private

  def modules_path
    path.join('src')
  end

  # TODO(thomthom): Refactor this into a mix-in module. Use custom attributes
  # to define accessors to config members. Maybe wrap the hash in a custom class
  # to easily read, write and access data.
  def load_library_config
    json = path.join(CONFIG_FILENAME).read
    JSON.parse(json, symbolize_names: true)
  end

end
