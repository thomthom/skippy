require 'json'
require 'pathname'

require_relative 'namespace'

class Skippy::Project

  PROJECT_FILENAME = 'skippy.json'.freeze

  attr_reader :name, :namespace, :path
  attr_accessor :description

  def initialize(path)
    @path = find_project_path(path) || path
    @namespace = Skippy::Namespace.new('Untitled')
    @name = ''
    @description = ''
  end

  def exist?
    File.exist?(filename)
  end

  def filename
    File.join(@path, PROJECT_FILENAME)
  end

  def name
    @name.empty? ? namespace_to_name(@namespace) : @name
  end

  def namespace=(namespace)
    @namespace = Skippy::Namespace.new(namespace)
  end

  def save
    File.write(filename, to_json)
  end

  def to_json
    project_config = {
      namespace: namespace,
      name: name,
      description: description
    }
    JSON.pretty_generate(project_config)
  end

  private

  def namespace_to_name(namespace)
    result = namespace.basename.scan(/([[:upper:]]+[[:lower:][:digit:]]*)/)
    return namespace if result.empty?
    result.join(' ')
  end

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
