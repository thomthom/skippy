require 'pathname'

require 'skippy/project'

class Skippy::Template

  attr_reader :name, :path
  attr_accessor :description

  # @param [String] relative_template_path Dirname of the template to use.
  def initialize(template_path)
    @path = Pathname.new(template_path)
    @name = @path.basename
    @description = ''
  end

  # @param [Skippy::Project] project
  # @param [Skippy::Command] context
  def compile(project, context)
    basename = project.namespace.to_underscore
    relative_paths.each { |source|
      target = source.to_s
      # Replaces the generic "extension" part of the template files to match the
      # extension's namespace.
      # Example: (Namespace: DeveloperName/AwesomeTool)
      #   extension.rb.erb      => awesome_tool.rb.erb
      #   extension/main.rb.erb => awesome_tool/main.rb.erb
      target.gsub!(/\A#{Regexp.quote(path)}\/extension/, "src/#{basename}")
      # Assumes the ERB template file contain the target file extension of the
      # target file.
      # Example:
      #   awesome_tool/main.rb.erb   => awesome_tool/main.rb
      #   awesome_tool/dialog.js.erb => awesome_tool/dialog.js
      path, filename = File.split(target)
      filename = File.basename(filename, '.erb')
      target = File.join(path, filename)
      # Render the template with the context of the Skippy::Command that runs
      # the template. This means the binding of the Skippy::Command is
      # available to the ERB template.
      context.send(:template, source.to_s, target)
    }
    nil
  end

  private

  # @return [Array<Pathname>] All ERB files in the template.
  def relative_paths
    pattern = File.join(path, '**', '*.erb')
    source_base = path.parent
    Dir.glob(pattern).map { |file|
      pathname = Pathname.new(file)
      pathname.relative_path_from(source_base)
    }
  end

end
