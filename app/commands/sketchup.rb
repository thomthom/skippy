# frozen_string_literal: true

require 'json'
require 'stringio'

require 'skippy/error'
require 'skippy/os'

class Sketchup < Skippy::Command

  include Thor::Actions

  option :port, :type => :numeric, :default => 7000
  option :rubyStartup, :type => :string, :default => ''
  option :skpFile, :type => :string, :default => ''

  desc 'debug VERSION [rubyStartup] [skpFile]', 'Start SketchUp with Ruby Debugger'
  def debug(version, ruby_startup = '', skp_file = '')
    app = find_sketchup(version)
    unless app.can_debug
      raise Skippy::Error, "Debug library not installed for Sketchup #{version}"
    end

    arguments = ['-rdebug', %("ide port=#{options.port}")]

    if ruby_startup != ''
      if ruby_startup.end_with?('.skp')
        skp_file = ruby_startup
      else
        arguments.append(['-RubyStartup', ruby_startup])
      end
    end

    if skp_file != ''
      arguments.append(skp_file)
    end

    Skippy.os.launch_app(app.executable, *arguments)
  end

  desc 'launch VERSION [rubyStartup] [skpFile]', 'Start SketchUp'
  def launch(version, ruby_startup = '', skp_file = '')
    app = find_sketchup(version)

    arguments = []

    if ruby_startup != ''
      if ruby_startup.end_with?('.skp')
        skp_file = ruby_startup
      else
        arguments.append(['-RubyStartup', ruby_startup])
      end
    end

    if skp_file != ''
      arguments.append(skp_file)
    end

    Skippy.os.launch_app(app.executable, *arguments)
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

  private

  # @param [Integer] version
  # @return [Skippy::SketchUpApp, nil]
  def find_sketchup(version)
    # Allow shortcuts such as 18 to mean 2018.
    full_version = version.to_i
    full_version += 2000 if (13..99).cover?(full_version)
    app = Skippy.os.sketchup_apps.find { |sketchup|
      sketchup.version == full_version
    }
    raise Skippy::Error, "SketchUp #{version} not found." if app.nil?

    app
  end

end
