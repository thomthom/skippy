require 'pathname'

require 'skippy/library'

class Skippy::LibModule

  attr_reader :path

  class ModuleNotFoundError < Skippy::Error; end

  def initialize(path)
    @path = Pathname.new(path)
    raise ModuleNotFoundError, @path.to_s unless @path.file?
  end

  # @param [String]
  def name
    path.basename('.*').to_s
  end

  def library
    Skippy::Library.new(library_path)
  end

  # @param [String]
  def to_s
    "#{library_name}/#{name}"
  end

  private

  def library_name
    library_path.basename.to_s
  end

  def library_path
    path.parent.parent
  end

end
