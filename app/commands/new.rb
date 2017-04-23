require 'json'

require 'skippy/app'
require 'skippy/group'
require 'skippy/project'

class New < Skippy::Command::Group

  include Thor::Actions

  argument :namespace,
    type: :string,
    desc: 'The namespace the extension will use'

  class_option :template,
    type: :string,
    desc: 'The template used to generate the project files',
    default: 'standard'

  source_paths << Skippy.app.resources

  attr_reader :project

  def initialize_project
    @project = Skippy::Project.new(Dir.pwd)
    if project.exist?
      raise Skippy::Error, "A project already exist: #{project.filename}"
    end
    project.namespace = namespace
    project.name = project.namespace.to_name
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
    say "Compiling template '#{options[:template]}'..."
    say ''
    directory(options[:template], 'src')
  end

  def create_extension_json
    extension_info = {
      name: project.name,
      description: project.description,
      creator: project.author,
      copyright: project.copyright,
      license: project.license,
      product_id: project.namespace.short_name,
      version: '0.1.0',
      build: '1',
    }
    json = JSON.pretty_generate(extension_info)
    json_filename = "src/#{ext_name}/extension.json"
    create_file(json_filename, json)
  end

  def create_example_skippy_command
    copy_file('commands/example.rb', 'skippy/commands/example.rb')
  end

  def finalize
    say ''
    say "Project for #{namespace} created.", :green
  end

  # These are methods to be used by the template engine when it compiles the
  # templates and expands the filenames.
  no_commands do

    # @return [String] The basename for the extension files.
    def ext_name
      # TODO: Add option to generate name based on lower case.
      project.namespace.short_name
    end

  end # no_commands

  # Needed as base for Thor::Actions' file actions.
  def self.source_root
    Skippy.app.templates_source_path
  end

end
