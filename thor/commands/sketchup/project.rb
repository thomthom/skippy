require 'json'
require 'pathname'

require_relative 'namespace'

class Skippy::Project

  PROJECT_FILENAME = 'skippy.json'.freeze

  def initialize(namespace)
    @path = find_project_path || Pathname.pwd
    if exist?
      # TODO(thomthom): Load existing project config.
      #load_project(filename)
    else
      @namespace = Skippy::Namespace.new(namespace)
    end
  end

  def exist?
    File.exist?(filename)
  end

  def filename
    File.join(@path, PROJECT_FILENAME)
  end

  def save
    File.write(filename, to_json)
  end

  def to_json
    project_config = {
      namespace: @namespace.to_s,
      name: 'Untitled',
      description: 'Lorem Ipsum'
    }
    JSON.pretty_generate(project_config)
  end

  private

  def find_project_path
    pathname = Pathname.new(Pathname.pwd)
    loop do
      project_file = pathname.join(PROJECT_FILENAME)
      return pathname if project_file.exist?
      break if pathname.root?
      pathname = pathname.parent
    end
    nil
  end

end
