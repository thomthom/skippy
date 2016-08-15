require 'json'

require 'skippy/command'

module Skippy::Namespace
  def self.valid?(namespace)
    parts = namespace.split('::')
    parts.all? { |part| /^[[:upper:]]/.match(part) }
  end
end

class Skippy::CLI < Skippy::Command

  desc 'new', 'Creates a new Skippy project in the current directory'
  def new(namespace)
    # Check for existing project.
    # TODO:

    # Validate namespace.
    unless Skippy::Namespace.valid?(namespace)
      raise Skippy::Error, "'#{namespace}' is not a valid Ruby namespace"
    end

    # Create project folders.
    # TODO: Use templates from Thor?

    # Create project JSON.
    project = {
      namespace: namespace,
      name: 'Untitled',
      description: 'Lorem Ipsum'
    }
    json = JSON.pretty_generate(project)
    say json
    skippy_json = File.join(Dir.pwd, 'skippy.json')
    say skippy_json

    say "Project for #{namespace} created.", :green
  end

end
