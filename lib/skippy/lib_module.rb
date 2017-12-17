require 'pathname'

require 'skippy/library'

class Skippy::LibModule

  attr_reader :path, :library

  class ModuleNotFoundError < Skippy::Error; end

  # @param [Skippy::Library] library
  # @param [String] path
  def initialize(library, path)
    @path = Pathname.new(path)
    raise ModuleNotFoundError, @path.to_s unless @path.file?
    @library = library
  end

  # @param [String]
  def basename
    path.basename('.*').to_s
  end

  def hash
    name.hash
  end

  # http://javieracero.com/blog/the-key-to-ruby-hashes-is-eql-hash
  def eql?(other)
    other.is_a?(self.class) && name.casecmp(other.name).zero?
  end

  # @param [String]
  def name
    "#{library.name}/#{basename}"
  end

  # @param [String]
  def to_s
    name
  end

end
