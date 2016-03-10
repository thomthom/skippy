require 'colorize'

require_relative 'debug.rb'
require_relative 'kernel.rb'


# Set up debugging.

options = {
  :debug => ARGV.include?('--debug'),
}

debug = Skippy::Debug.new(options[:debug])


# Extract command line arguments.
# TODO: Use optparse.

debug.puts 'CLI arguments'.cyan
debug.p ARGV

command_name = ARGV.pop


# Set up paths.

path_skippy = File.expand_path(File.join(__dir__, '..'))
path_bin = File.join(path_skippy, 'bin')
path_lib = File.join(path_skippy, 'lib')
path_lib_public = File.join(path_lib, 'public')
path_commands = File.join(path_skippy, 'commands')

debug.puts 'Skippy Paths:'.cyan
debug.puts "BIN: #{path_bin}".yellow
debug.puts "LIB: #{path_lib}".yellow
debug.puts "CMD: #{path_commands}".yellow

options[:paths] = {
  :skippy   => path_skippy,
  :bin      => path_bin,
  :lib      => path_lib,
  :public   => path_lib_public,
  :commands => path_commands,
}


# Add the Skippy lib path to load path.

$LOAD_PATH << options[:paths][:public]


begin
  kernel = Skippy::Console::Kernel.new(options)
  command = kernel.command(command_name)

  debug.puts 'Command:'.cyan
  debug.puts command.signature.yellow
  debug.puts command.description.yellow

  command.run
rescue Skippy::Console::KernelError => error
  puts error.message.red
end
