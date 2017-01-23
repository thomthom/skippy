require 'json'
require 'pathname'

require 'skippy/helpers/file'
require 'skippy/library'
require 'skippy/project'

class Skippy::LibraryManager

  include Enumerable
  include Skippy::Helpers::File

  attr_reader :project

  # @param [Skippy::Project] project
  def initialize(project)
    raise TypeError, 'expected a Project' unless project.is_a?(Skippy::Project)
    @project = project
  end

  # @yield [Skippy::Library]
  def each
    directories(path).map { |lib_path|
      yield Skippy::Library.new(lib_path)
    }
  end

  def empty?
    to_a.empty?
  end

  # @param [Pathname, String] source
  def install(source)
    raise Skippy::Project::ProjectNotSavedError unless project.exist?
    library = Skippy::Library.new(source)

    target = path.join(library.name)

    FileUtils.mkdir_p(path)
    FileUtils.copy_entry(source, target)

    project.config.push(:libraries, {
      name: library.name,
      version: library.version,
      source: source
    })

    project.save

    library
  end

  # @return [Integer]
  def length
    to_a.length
  end
  alias :size :length

  # @return [Pathname]
  def path
    project.path('.skippy/libs')
  end

end
