require 'json'
require 'pathname'

require 'skippy/helpers/file'
require 'skippy/config'
require 'skippy/config_accessors'
require 'skippy/library'
require 'skippy/namespace'

class Skippy::Project

  extend Skippy::ConfigAccessors

  include Skippy::Helpers::File

  PROJECT_FILENAME = 'skippy.json'.freeze

  attr_reader :path

  config_attr :author, :copyright, :description, :license, :name
  config_attr :namespace, type: Skippy::Namespace

  class ProjectNotFoundError < RuntimeError; end

  # @return [Skippy::Project]
  def self.current_or_fail
    project = Skippy::Project.new(Dir.pwd)
    raise ProjectNotFoundError unless project.exist?
    project
  end

  # Initialize a project for the provided path. If the path is within a project
  # path the base path of the project will be found. Otherwise it's assumed that
  # the path is the base for a new project.
  #
  # @param [Pathname, String] path
  def initialize(path)
    @path = find_project_path(path) || Pathname.new(path)
    # noinspection RubyResolve
    @config = Skippy::Config.load(filename, defaults)
  end

  # @yield [filename]
  # @yieldparam [String] filename the path to custom Skippy command
  def command_files(&block)
    files_pattern = File.join(path, 'skippy', '**', '*.rb')
    Dir.glob(files_pattern) { |filename|
      block.call(filename)
    }
  end

  # Checks if a project exist on disk. If not it's just transient.
  def exist?
    filename.exist?
  end

  # Full path to the project's configuration file. This file may not exist.
  # @return [Pathname]
  def filename
    path.join(PROJECT_FILENAME)
  end

  # @return [Array<Skippy::Library>]
  def libraries
    directories(libraries_path).map { |lib_path|
      Skippy::Library.new(lib_path)
    }
  end

  def libraries_path
    path.join('.skippy/libs')
  end

  # Commits the project to disk.
  def save
    @config.save_as(filename)
  end

  # @return [String]
  def to_json
    JSON.pretty_generate(@config)
  end

  private

  def defaults
    {
      name: 'Untitled',
      description: '',
      namespace: Skippy::Namespace.new('Untitled'),
      author: 'Unknown',
      copyright: "Copyright (c) #{Time.now.year}",
      license: 'None',
    }
  end

  # Finds the root of a project based on any path within the project.
  #
  # @param [String] path
  # return [Pathname, nil]
  def find_project_path(path)
    pathname = Pathname.new(path)
    loop do
      project_file = pathname.join(PROJECT_FILENAME)
      return pathname if project_file.exist?
      break if pathname.root?
      pathname = pathname.parent
    end
    nil
  end

end
