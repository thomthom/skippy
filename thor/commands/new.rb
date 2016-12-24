require 'skippy/group'
require 'skippy/project'
require 'skippy/template'

class New < Skippy::Command::Group

  include Thor::Actions

  argument :namespace,
    :type => :string,
    :desc => 'The namespace the extension will use'

  desc 'Creates a new Skippy project in the current directory'

  attr_reader :project

  def initialize_project
    @project = Skippy::Project.new(Dir.pwd)
    if project.exist?
      raise Skippy::Error, "A project already exist: #{project.filename}"
    end
    project.namespace = namespace
  end

  def create_project_json
    say ''
    say 'Generating skippy.json...'
    say ''
    say project.filename
    say project.to_json, :yellow
    project.save
  end

  def create_project_files
    say ''
    say 'Generating template files...'
    say ''
    # TODO(thomthom): Take an argument that control which template to use.
    template_engine = Skippy::Template.new('minimal')
    template_engine.compile(project, self)
  end

  def finalize
    say ''
    say "Project for #{namespace} created.", :green
  end

  # Needed as base for Thor::Actions' file actions.
  def self.source_root
    path = File.join(__dir__, '..', '..', 'thor', 'templates')
    File.expand_path(path)
  end

end
