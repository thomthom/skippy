require 'fileutils'
require 'json'

class Lib < Skippy::Command

  include Thor::Actions

  desc 'list', 'List installed libraries'
  def list
    say 'Available libraries:', :yellow
    project = Skippy::Project.current_or_fail
    libraries = project.libraries
    if libraries.empty?
      say '  No libraries available'
    else
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

  desc 'install', 'Install a new library'
  def install(source)
    lib_name = File.basename(source)
    target = File.join('.skippy/libs', lib_name)

    FileUtils.mkdir_p('.skippy/libs')
    FileUtils.copy_entry(source, target)

    lib_json = File.read(File.join(target, 'skippy.json'))
    lib_config = JSON.parse(lib_json, symbolize_names: true)

    version = lib_config[:version]

    project = Skippy::Project.new(Dir.pwd)
    project_json = File.read(project.filename)
    project_config = JSON.parse(project_json, symbolize_names: true)

    project_config[:libraries] ||= []
    project_config[:libraries] << {
      name: lib_name,
      version: version,
      source: source
    }

    File.write(project.filename, JSON.pretty_generate(project_config))

    say "Installed library: #{lib_name} (#{version})"
  end

  desc 'use', 'Use a library module'
  def use(module_path)
    #project = Skippy::Project.current_or_fail
    project = Skippy::Project.new(Dir.pwd)

    lib_name, module_name = module_path.split('/')
    # project.path(relative_path)
    lib_file = File.join(project.path, ".skippy/libs/#{lib_name}/src/#{module_name}.rb")

    # project.vendor_path(lib_name)
    vendor_file = File.join(project.path, "src/#{project.namespace.to_underscore}/vendor/#{lib_name}/#{module_name}.rb")

    source_paths << project.path

    copy_file lib_file, vendor_file do |content|
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
