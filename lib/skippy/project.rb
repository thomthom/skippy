# frozen_string_literal: true

require 'json'
require 'pathname'

require 'skippy/helpers/file'
require 'skippy/config'
require 'skippy/config_accessors'
require 'skippy/error'
require 'skippy/library_manager'
require 'skippy/namespace'
require 'skippy/module_manager'

class Skippy::Project

  extend Skippy::ConfigAccessors

  include Skippy::Helpers::File

  PROJECT_FILENAME = 'skippy.json'.freeze

  attr_reader :config
  attr_reader :libraries
  attr_reader :modules

  config_attr :author, :copyright, :description, :license, :name
  config_attr :namespace, type: Skippy::Namespace

  class ProjectNotFoundError < Skippy::Error; end
  class ProjectNotSavedError < Skippy::Error; end

  # @return [Skippy::Project, nil]
  def self.current
    Skippy::Project.new(Dir.pwd)
  end

  # @return [Skippy::Project]
  def self.current_or_fail
    project = current
    raise ProjectNotFoundError, project.filename unless project.exist?

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
    @libraries = Skippy::LibraryManager.new(self)
    @modules = Skippy::ModuleManager.new(self)
  end

  # The basename for the extension's root and support folder.
  #
  # @return [String]
  def basename
    @config.get(:basename, namespace.short_name)
  end

  # @param [String] basename
  def basename=(basename)
    @config.set(:basename, basename)
  end

  # @yield [filename]
  # @yieldparam [String] filename the path to custom Skippy command
  def command_files
    files_pattern = File.join(path, 'skippy', '**', '*.rb')
    Dir.glob(files_pattern) { |filename|
      yield filename
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

  # @param [Pathname, String] sub_path
  # @return [Pathname]
  def path(sub_path = '')
    @path.join(sub_path)
  end

  # Commits the project to disk.
  def save
    @config.set(:libraries, libraries.map(&:to_h))
    @config.set(:modules, modules.map(&:name))
    @config.save_as(filename)
  end

  # @return [Pathname]
  def extension_source
    path.join('src')
  end

  # @return [Array<String>]
  def sources
    @config.get(:sources, defaults[:sources])
  end

  # @return [String]
  def to_json(*args)
    JSON.pretty_generate(@config, *args)
  end

  private

  # @return [Hash]
  def defaults
    {
      name: 'Untitled',
      description: '',
      namespace: Skippy::Namespace.new('Untitled'),
      basename: Skippy::Namespace.new('Untitled').short_name,
      author: 'Unknown',
      copyright: "Copyright (c) #{Time.now.year}",
      license: 'None',
      sources: %w(
        github.com
        bitbucket.org
      ),
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
