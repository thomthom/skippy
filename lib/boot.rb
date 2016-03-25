require 'colorize'

require_relative 'skippy/config'


config = Skippy::Config.new(__dir__)

$LOAD_PATH << config.path_lib


require 'skippy/console/kernel.rb'
require 'skippy/debug'


options = {
  :debug => ARGV.include?('--debug'),
}

debug = Skippy::Debug.new(options[:debug])

debug.puts 'Skippy Paths:'.cyan
debug.puts "BIN: #{config.path_bin}".yellow
debug.puts "LIB: #{config.path_lib}".yellow
debug.puts "CMD: #{config.path_commands}".yellow


# Extract command line arguments.
# TODO: Use optparse.

debug.puts 'CLI arguments'.cyan
debug.p ARGV

command_name = ARGV.shift


begin
  kernel = Skippy::Console::Kernel.new(config)
  command = kernel.command(command_name)

  debug.puts 'Command:'.cyan
  debug.puts command.signature.yellow
  debug.puts command.description.yellow

  command.run
rescue Skippy::Console::KernelError => error
  puts error.message.white.on_red # TODO: Use Skippy::Console::Printer
end
