require 'skippy/os/common'
require 'skippy/sketchup/app'

class Skippy::OSMac < Skippy::OSCommon

  def sketchup_apps
    apps = []
    pattern = '/Applications/SketchUp */'
    Dir.glob(pattern) { |path|
      app = File.join(path, 'SketchUp.app')
      debug_lib = File.join(app, 'Contents/Frameworks/SURubyDebugger.dylib')
      version = File.basename(path).match(/[0-9.]+$/)[0].to_i
      apps << Skippy::SketchUpApp.from_hash(
        executable: app,
        version: version,
        can_debug: File.exist?(debug_lib),
        is64bit: version > 2015,
      )
    }
    apps.sort_by(&:version)
  end

end
