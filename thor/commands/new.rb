require 'json'

require 'skippy/app'
require 'skippy/group'
require 'skippy/project'
require 'skippy/template'

class New < Skippy::Command::Group

  include Thor::Actions

  argument :namespace,
    :type => :string,
    :desc => 'The namespace the extension will use'

  class_option :template,
    :type => :string,
    :desc => 'The template used to generate the project files',
    :default => 'standard'

  attr_reader :project

  def initialize_project
    @project = Skippy::Project.new(Dir.pwd)
    if project.exist?
      raise Skippy::Error, "A project already exist: #{project.filename}"
    end
    project.namespace = namespace
  end

  def validate_template
    template_path = File.join(self.class.source_root, options[:template])
    unless File.directory?(template_path)
      raise Skippy::Error, %(Template "#{options[:template]}" not found)
    end
  end

  def create_project_json
    say ''
    say 'Generating skippy.json...'
    say ''
    say project.filename
    say project.to_json, :yellow
    project.save
  end

  def compile_templates
    say ''
    say 'Generating template files...'
    say "Template: #{options[:template]}"
    say ''
    template_path = File.join(self.class.source_root, options[:template])
    template_engine = Skippy::Template.new(template_path)
    template_engine.compile(project, self)
  end

  def create_extension_json
    extension_info = {
      name: project.name,
      description: project.description,
      creator: project.author,
      copyright: project.copyright,
      license: project.license,
      product_id: project.namespace.to_a.join('_'),
      version: "0.1.0",
      build: "1",
    }
    json = JSON.pretty_generate(extension_info)
    json_filename = "src/#{project.namespace.to_underscore}/extension.json"
    create_file(json_filename, json)
  end

  def create_example_skippy_command
    example_path = Skippy.app.resources('example.rb')
    example = File.read(example_path)
    filename = 'skippy/example.rb'
    create_file(filename, example)
  end

  def finalize
    say ''
    say "Project for #{namespace} created.", :green
  end

  # Needed as base for Thor::Actions' file actions.
  def self.source_root
    Skippy.app.templates_source_path
  end

end
