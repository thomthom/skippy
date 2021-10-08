# frozen_string_literal: true

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
        say "#{library.name} (#{library.version})", [:bold, :yellow]
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
    type: :string
  method_option :branch,
    aliases: ['-b'],
    type: :string
  desc 'install SOURCE', 'Install a new library'
  def install(source)
    project = Skippy::Project.current_or_fail
    libraries = project.libraries
    installation_options = install_options(options)
    library = libraries.install(source, installation_options) { |type, message|
      color = type == :warning ? :red : :yellow
      say message, color
    }
    project.save
    say "Installed library: #{library.name} (#{library.version})"
  end

  desc 'uninstall LIBRARY', 'Uninstall a library'
  def uninstall(library_name)
    project = Skippy::Project.current_or_fail
    library = project.libraries.uninstall(library_name)
    project.save
    say "Uninstalled library: #{library.name} (#{library.version})"
  end

  desc 'use MODULE', 'Use a library module'
  def use(module_path)
    project = Skippy::Project.current_or_fail
    lib_module = project.modules.use(module_path)
    project.save
    say "Using module: #{lib_module}"
  end

  desc 'remove MODULE', 'Remove a library module'
  def remove(module_path)
    project = Skippy::Project.current_or_fail
    lib_module = project.modules.remove(module_path)
    project.save
    say "Removed module: #{lib_module}"
  end

  private

  def install_options(cli_options)
    options = cli_options.transform_keys(&:to_sym)
    # The CLI options "version" is internally a "requirement".
    if options.key?(:version)
      options[:requirement] = options[:version]
      options.delete(:version)
    end
    options
  end

end
