require 'json'
require 'pathname'

require 'skippy/helpers/file'
require 'skippy/library'
require 'skippy/namespace'

class Skippy::Project

  include Skippy::Helpers::File

  PROJECT_FILENAME = 'skippy.json'.freeze

  attr_reader :namespace, :path, :author, :copyright, :license
  attr_accessor :description

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
    config = load_config
    @namespace = Skippy::Namespace.new(config[:namespace] || 'Untitled')
    @name = config[:name] || ''
    @description = config[:description] || ''
    @author = config[:author] || 'Unknown'
    @copyright = config[:copyright] || "Copyright (c) #{Time.now.year}"
    @license = config[:license] || 'None'
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
    File.exist?(filename)
  end

  # Full path to the project's configuration file. This file may not exist.
  # @return [String]
  def filename
    File.join(path, PROJECT_FILENAME)
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

  # @return [String]
  def name
    @name.empty? ? namespace.to_name : @name
  end

  # @param [String] namespace
  def namespace=(namespace)
    @namespace = Skippy::Namespace.new(namespace)
  end

  # Commits the project to disk.
  def save
    File.write(filename, to_json)
  end

  # @return [String]
  def to_json
    project_config = {
      namespace: namespace,
      name: name,
      description: description
    }
    JSON.pretty_generate(project_config)
  end

  private

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

  # return [Hash]
  def load_config
    return {} unless exist?
    json = File.read(filename)
    JSON.parse(json, symbolize_names: true)
  end

end
