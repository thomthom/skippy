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

  def <=>(other)
    other.is_a?(self.class) ? name <=> other.name : nil
  end

  def eql?(other)
    # http://javieracero.com/blog/the-key-to-ruby-hashes-is-eql-hash
    other.is_a?(self.class) && name.casecmp(other.name).zero?
  end

  # @param [String]
  def basename
    path.basename('.*').to_s
  end

  def hash
    name.hash
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
