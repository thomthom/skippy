require 'pathname'

class Skippy::LibModule

  attr_reader :path

  class ModuleNotFoundError < RuntimeError; end

  def initialize(path)
    @path = Pathname.new(path)
    raise ModuleNotFoundError, @path.to_s unless @path.exist?
  end

  def name
    path.basename('.*').to_s
  end

  def to_s
    "#{library_name}/#{name}"
  end

  private

  def library_name
    path.parent.parent.basename.to_s
  end

end
