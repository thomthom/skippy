require 'fileutils'
require 'json'

require 'skippy/library'
require 'skippy/project'

class Lib < Skippy::Command

  include Thor::Actions

  desc 'list', 'List installed libraries'
  def list
    project = Skippy::Project.current_or_fail
    libraries = project.libraries
    if libraries.empty?
      say 'No libraries installed', :yellow
    else
      say 'Installed libraries:', :yellow
      libraries.each { |library|
        say
        say "#{library.title} (#{library.version})", [:bold, :yellow]
        library.modules.each { |lib_module|
          lib_info = "  #{lib_module}"
          lib_info << ' (installed)' if project.modules.installed?(lib_module)
          say lib_info, :green
        }
      }
    end
  end
  default_command(:list)

  method_option :version,
    aliases: ['-v'],
    # banner: 'Either a tag, "latest" or "edge".',
    type: :string
  method_option :branch,
    aliases: ['-b'],
    type: :string
  desc 'install SOURCE', 'Install a new library'
  def install(source)
    project = Skippy::Project.current_or_fail

    # Prints a text-based "spinner" element while work occurs.
    # spinner = Enumerator.new do |e|
    #   loop do
    #     e.yield '|'
    #     e.yield '/'
    #     e.yield '-'
    #     e.yield '\\'
    #   end
    # end

    # In new thread?
    # 1.upto(100) do |i|
    #   printf("\rSpinner: %s", spinner.next)
    #   sleep(0.1)
    # end

    # say options.inspect
    install_options = options.map { |k, v| [k.to_sym, v] }.to_h
    library = project.libraries.install(source, install_options) { |type, message|
      color = type == :warning ? :red : :yellow
      say message, color
    }
    say "Installed library: #{library.name} (#{library.version})"
  end

  desc 'use MODULE', 'Use a library module'
  def use(module_path)
    project = Skippy::Project.current_or_fail
    lib_module = project.modules.use(module_path)
    say "Using module: #{lib_module}"
  end

end
