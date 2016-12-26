require 'json'
require 'pathname'

require 'skippy/namespace'

class Skippy::Project

  PROJECT_FILENAME = 'skippy.json'.freeze

  attr_reader :name, :namespace, :path, :author, :copyright, :license
  attr_accessor :description

  # Initialize a project for the provided path. If the path is within a project
  # path the base path of the project will be found. Otherwise it's assumed that
  # the path is the base for a new project.
  #
  # @param [Pathname, String] path
  def initialize(path)
    @path = find_project_path(path) || Pathname.new(path)
    @namespace = Skippy::Namespace.new('Untitled')
    @name = ''
    @description = ''
    @author = 'Unknown'
    @copyright = "Copyright (c) #{Time.now.year}"
    @license = 'None'
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

end
