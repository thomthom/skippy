require 'json'
require 'stringio'

class Sketchup < Skippy::Command

  include Thor::Actions

  option :port, :type => :numeric, :default => 7000
  desc 'debug VERSION', 'Start SketchUp with Ruby Debugger'
  def debug(version)
    sketchup = find_sketchup(version)
    command = %("#{sketchup}" -rdebug "ide port=#{options.port}")
    spawn(command)
  end

  desc 'launch VERSION', 'Start SketchUp'
  def launch(version)
    sketchup = find_sketchup(version)
    command = %("#{sketchup}"")
    spawn(command)
  end

  desc 'list', 'List all known SketchUp versions'
  def list
    say shell.set_color('Known SketchUp versions:', :yellow, true)
    find_all_sketchup.each { |sketchup|
      version = sketchup[:version].to_s.ljust(4)
      sketchup_name = "SketchUp #{version}"
      bitness = sketchup[:is64bit] ? '64bit' : '32bit'
      debug = sketchup[:can_debug] ? '(debugger)' : ''
      # TODO(thomthom): Use print_table ?
      output = StringIO.new
      output.write '  '
      output.write shell.set_color(sketchup_name, :green, true)
      output.write '   '
      output.write bitness
      output.write '   '
      output.write shell.set_color(debug, :yellow, false)
      say output.string
    }
  end
  default_command(:list)

  private # TODO(thomthom): Move private methods to System module.

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


  def find_all_sketchup
    if RUBY_PLATFORM =~ /darwin/
      result = find_all_sketchup_mac
    else
      result = find_all_sketchup_win
    end
    result.sort! { |a, b| a[:version] <=> b[:version] }
    result
  end

  def find_all_sketchup_mac
    raise NotImplementedError, 'Mac support not implemented'
  end

  POINTER_SIZE = ['a'].pack('P').size * 8
  SYSTEM_64BIT = POINTER_SIZE == 64
  SYSTEM_32BIT = POINTER_SIZE == 32

  PROGRAM_FILES_64BIT = File.expand_path(ENV['ProgramW6432'])

  def find_all_sketchup_win
    # TODO(thomthom): Find by registry information.
    result = []
    program_files_paths.each { |program_files|
      # pattern = File.join(program_files, 'SketchUp', 'SketchUp *')
      pattern = "#{program_files}/{@Last Software,Google,SketchUp}/*SketchUp *"
      Dir.glob(pattern) { |path|
        exe = File.join(path, 'SketchUp.exe')
        debug_dll = File.join(path, 'SURubyDebugger.dll')
        version = File.basename(path).match(/[0-9.]+$/)[0].to_i
        result << {
          executable: exe,
          version: version,
          can_debug: File.exist?(debug_dll),
          is64bit: SYSTEM_64BIT && path.start_with?("#{PROGRAM_FILES_64BIT}/"),
        }
      }
    }
    result
  end


  def find_sketchup(version)
    if RUBY_PLATFORM =~ /darwin/
      sketchup = find_sketchup_mac(version)
    else
      sketchup = find_sketchup_win(version)
    end
    raise "SketchUp #{version} not found." if sketchup.nil?
    sketchup
  end

  def find_sketchup_win(version)
    # TODO(thomthom): Find by registry information.
    # Look for 32bit or 64bit SketchUp in default installation directory.
    paths = program_files_paths.map { |program_files|
      path = File.join(program_files, 'SketchUp', "SketchUp #{version}")
      sketchup = File.join(path, 'SketchUp.exe')
      File.expand_path(sketchup)
    }
    paths.find { |path| File.exist?(path) }
  end

  def find_sketchup_mac(version)
    raise NotImplementedError, 'Mac support not implemented'
  end

end
