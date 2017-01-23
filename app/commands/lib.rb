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
          say "  #{lib_module}", :green
        }
      }
    end
  end
  default_command(:list)

  desc 'install SOURCE', 'Install a new library'
  def install(source)
    project = Skippy::Project.current_or_fail
    library = project.libraries.install(source)
    say "Installed library: #{library.name} (#{library.version})"
  end

  desc 'use MODULE', 'Use a library module'
  def use(module_path)
    project = Skippy::Project.current_or_fail

    # TODO(thomthom): project.modules.use(module_path)
    lib_name, module_name = module_path.split('/')
    # project.path(relative_path)
    lib_file = File.join(project.path, ".skippy/libs/#{lib_name}/src/#{module_name}.rb")

    # project.vendor_path(lib_name)
    # project.modules.path(lib_name)
    vendor_file = File.join(project.path, "src/#{project.namespace.to_underscore}/vendor/#{lib_name}/#{module_name}.rb")

    source_paths << project.path

    copy_file lib_file, vendor_file do |content|
      # Transform library namespace to project namespace.
      content.gsub!('SkippyLib', project.namespace)
      content
    end

    project_json = File.read(project.filename)
    project_config = JSON.parse(project_json, symbolize_names: true)

    project_config[:modules] ||= []
    project_config[:modules] << module_path

    File.write(project.filename, JSON.pretty_generate(project_config))
  end

end
