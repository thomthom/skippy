require 'skippy/command'

require_relative 'sketchup/project'

class Skippy::CLI < Skippy::Command
  include Thor::Actions

  # TODO(thomthom): Refactor this into a Thor::Group?
  desc 'new', 'Creates a new Skippy project in the current directory'
  def new(namespace)
    project = Skippy::Project.new(Dir.pwd)

    if project.exist?
      raise Skippy::Error, "A project already exist: #{project.filename}"
    end

    project.namespace = namespace

    say ''
    say 'Generating skippy.json...'
    say ''
    say project.filename
    say project.to_json, :yellow
    project.save

    say ''
    say 'Generating template files...'
    say ''
    # TODO(thomthom): Refactor this into a separate class that can take a folder
    # and process it.
    options = { :namespace => project.namespace.to_s }
    basename = project.namespace.to_underscore
    template('new/extension.erb', "src/#{basename}.rb", options)
    template('new/extension/main.erb', "src/#{basename}/main.rb", options)

    say ''
    say "Project for #{namespace} created.", :green
  end

  def self.source_root
    path = File.join(__dir__, '..', '..', 'thor', 'templates')
    File.expand_path(path)
  end

end
