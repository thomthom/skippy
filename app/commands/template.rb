class Template < Skippy::Command

  desc 'list', 'List all known templates'
  def list
    say 'Available templates:', :yellow
    templates = Skippy.app.templates
    if templates.empty?
      say '  No templates found'
    else
      templates.each { |template|
        say "  #{template}", :green
      }
    end
  end
  default_command(:list)

  desc 'install', 'Install a new template'
  def install(source)
    raise Skippy::Error, 'Not implemented'
  end

  desc 'remove', 'Remove an installed template'
  def remove(template_name)
    raise Skippy::Error, 'Not implemented'
  end

end
