require 'pathname'

require 'skippy/library'

class Skippy::LibModule

  attr_reader :path

  class ModuleNotFoundError < Skippy::Error; end

  # @param [String] path
  def initialize(path)
    @path = Pathname.new(path)
    raise ModuleNotFoundError, @path.to_s unless @path.file?
  end

  # @param [String]
  def basename
    path.basename('.*').to_s
  end

  # @return [Skippy::Library]
  def library
    Skippy::Library.new(library_path)
  end

  # @param [String]
  def name
    "#{library.name}/#{basename}"
  end

  # @param [String]
  def to_s
    name
  end

  private

  def library_path
    # KLUDGE:
    if path.parent.basename.to_s == 'modules'
      path.parent.parent
    else
      lib_name = path.parent.basename.to_s
      project = Skippy::Project.current_or_fail
      project.libraries.find_library(lib_name).path
    end
  end

end
