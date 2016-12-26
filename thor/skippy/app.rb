require 'pathname'

require 'skippy/skippy'

class Skippy::App

  # @param [String] boot_loader_path
  # @return [Skippy::App]
  def self.boot(boot_loader_path)
    Skippy.app = Skippy::App.new(boot_loader_path)
  end

  attr_reader :path

  # @param [String] boot_loader_path
  def initialize(boot_loader_path)
    @boot_loader_path = File.expand_path(boot_loader_path)
    @path = File.dirname(@boot_loader_path)
    boot_commands
  end

  # @return [Array<String>]
  def templates_source_path
    Pathname.new(File.join(path, 'templates'))
  end

  def templates
    result = []
    templates_source_path.entries.each { |entry|
      template_path =  templates_source_path.join(entry)
      next unless template_path.directory?
      next if %[. ..].include?(entry.basename.to_s)
      result << Skippy::Template.new(entry)
    }
    result
  end

  private

  # @return [Array<String>] loaded files
  def boot_commands
    # Load the default skippy commands.
    path_commands = File.join(path, 'commands')
    commands_pattern = File.join(path_commands, '*.rb')
    Dir.glob(commands_pattern) { |filename|
      require filename
    }
  end

end