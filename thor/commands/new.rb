require 'json'

require 'skippy/command'

require_relative 'sketchup/project'

class Skippy::CLI < Skippy::Command

  desc 'new', 'Creates a new Skippy project in the current directory'
  def new(namespace)
    project = Skippy::Project.new(namespace)

    if project.exist?
      raise Skippy::Error, "A project already exist: #{project.filename}"
    end

    say project.to_json
    say project.filename

    # TODO(thomthom): Prompt user for title and description?

    # TODO(thomthom): Call init to create project files and folders.
    # TODO(thomthom): Use templates from Thor?
    #project.init
    project.save

    say "Project for #{namespace} created.", :green
  end

end
