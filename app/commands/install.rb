require 'json'

require 'skippy/app'
require 'skippy/group'
require 'skippy/project'

class Install < Skippy::Command::Group

  attr_reader :project

  def initialize_project
    @project = Skippy::Project.current_or_fail
  end

  def installing_libraries
    say ''
    say 'Installing libraries...'
    say ''
    project.config.get(:libraries, []).each { |library|
      say 'Missing library version', :red if library[:version].nil?
      say 'Missing library source', :red if library[:source].nil?
      next if library[:version].nil? || library[:source].nil?

      options = {
        requirement: library[:version],
      }
      options[:branch] = library[:branch] unless library[:branch].nil?
      lib = project.libraries.install(library[:source], options)

      unless lib.version == library[:version]
        say "Expected version #{library[:version]}, got #{lib.version}", :red
      end

      say "Installed library: #{lib.name} (#{lib.version})", :green
      say lib.path
    }
    # Don't save project - as all that is being done here is installing missing
    # library cache into the .skippy directory.
  end

end
