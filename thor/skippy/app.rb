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
    @boot_loader_path = boot_loader_path
    @path = File.dirname(boot_loader_path)
    boot_commands
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