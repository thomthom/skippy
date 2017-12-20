require 'skippy/os/common'
require 'skippy/sketchup/app'

class Skippy::OSWin < Skippy::OSCommon

  # Note: This is not a good indication to 32bit bs 64bit. It's a naive
  #       assumption that will fail when SketchUp is installed to a
  #       non-standard location.
  SYSTEM_32BIT = ENV['ProgramFiles(x86)'].nil? && ENV['ProgramW6432'].nil?
  SYSTEM_64BIT = !SYSTEM_32BIT

  PROGRAM_FILES_64BIT = File.expand_path(ENV['ProgramW6432'])

  # @param [String] executable_path
  def launch_app(executable_path, *args)
    command = %("#{executable_path}")
    unless args.empty?
      command << " #{args.join(' ')}"
    end
    execute_command(command)
  end

  def sketchup_apps
    # TODO(thomthom): Find by registry information.
    apps = []
    program_files_paths.each { |program_files|
      pattern = "#{program_files}/{@Last Software,Google,SketchUp}/*SketchUp *"
      Dir.glob(pattern) { |path|
        exe = File.join(path, 'SketchUp.exe')
        debug_dll = File.join(path, 'SURubyDebugger.dll')
        version = File.basename(path).match(/[0-9.]+$/)[0].to_i
        apps << Skippy::SketchUpApp.from_hash(
          executable: exe,
          version: version,
          can_debug: File.exist?(debug_dll),
          is64bit: SYSTEM_64BIT && path.start_with?("#{PROGRAM_FILES_64BIT}/"),
        )
      }
    }
    apps.sort_by(&:version)
  end

  private

  def program_files_paths
    paths = []
    if SYSTEM_64BIT
      paths << File.expand_path(ENV['ProgramFiles(x86)'])
      paths << File.expand_path(ENV['ProgramW6432'])
    else
      paths << File.expand_path(ENV['ProgramFiles'])
    end
    paths
  end

end
