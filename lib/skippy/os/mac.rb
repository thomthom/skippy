require 'skippy/os/common'
require 'skippy/sketchup/app'

class Skippy::OSMac < Skippy::OSCommon

  # @param [String] executable_path
  def launch_app(executable_path, *args)
    command = %(open -a "#{executable_path}")
    unless args.empty?
      command << " --args #{args.join(' ')}"
    end
    execute_command(command)
  end

  def sketchup_apps
    apps = []
    pattern = '/Applications/SketchUp */'
    Dir.glob(pattern) { |path|
      app = File.join(path, 'SketchUp.app')
      debug_lib = File.join(app, 'Contents/Frameworks/SURubyDebugger.dylib')
      version = sketchup_version_from_path(path)
      next unless version

      apps << Skippy::SketchUpApp.from_hash(
        executable: app,
        version: version,
        can_debug: File.exist?(debug_lib),
        is64bit: version > 2015
      )
    }
    apps.sort_by(&:version)
  end

end
