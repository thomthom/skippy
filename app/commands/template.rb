class Template < Skippy::Command

  desc 'list', 'List all known templates'
  def list
    say 'Available templates:', :yellow
    templates = Skippy.app.templates
    if templates.empty?
      say '  No templates found'
    else
      templates.each { |template|
        say "  #{template.basename}", :green
      }
    end
  end
  default_command(:list)

  desc 'install SOURCE', 'Install a new template'
  def install(_source)
    raise Skippy::Error, 'Not implemented'
  end

  desc 'remove TEMPLATE', 'Remove an installed template'
  def remove(_template_name)
    raise Skippy::Error, 'Not implemented'
  end

end
