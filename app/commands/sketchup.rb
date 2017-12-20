require 'json'
require 'stringio'

require 'skippy/error'
require 'skippy/os'

class Sketchup < Skippy::Command

  include Thor::Actions

  option :port, :type => :numeric, :default => 7000
  desc 'debug VERSION', 'Start SketchUp with Ruby Debugger'
  def debug(version)
    sketchup = find_sketchup(version)
    command = %("#{sketchup}" -rdebug "ide port=#{options.port}")
    execute_command(command)
  end

  desc 'launch VERSION', 'Start SketchUp'
  def launch(version)
    app = Skippy.os.sketchup_apps.find { |sketchup|
      sketchup.version == version.to_i
    }
    raise Skippy::Error, "SketchUp #{version} not found." if app.nil?
    Skippy.os.launch_app(app.executable)
  end

  desc 'list', 'List all known SketchUp versions'
  def list
    say shell.set_color('Known SketchUp versions:', :yellow, true)
    Skippy.os.sketchup_apps.each { |sketchup|
      version = sketchup.version.to_s.ljust(4)
      sketchup_name = "SketchUp #{version}"
      bitness = sketchup.is64bit ? '64bit' : '32bit'
      debug = sketchup.can_debug ? '(debugger)' : ''
      # TODO(thomthom): Use print_table ?
      output = StringIO.new
      output.write '  '
      output.write shell.set_color(sketchup_name, :green, false)
      output.write '   '
      output.write bitness
      output.write '   '
      output.write shell.set_color(debug, :yellow, false)
      say output.string
    }
  end
  default_command(:list)

end
