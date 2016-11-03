require 'skippy/group'
require 'skippy/project'

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
    # TODO(thomthom): Refactor this into a separate class that can take a folder
    # and process it.
    options = { :namespace => project.namespace.to_s }
    basename = project.namespace.to_underscore
    template('new/extension.erb', "src/#{basename}.rb", options)
    template('new/extension/main.erb', "src/#{basename}/main.rb", options)
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
