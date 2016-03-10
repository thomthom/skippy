require 'colorize'

require_relative 'debug.rb'


# Extract command line arguments.

debug 'CLI arguments'.cyan
debug_p ARGV

# TODO: Use optparse.
command_name = ARGV.pop


# Set up paths.

path_skippy = File.expand_path(File.join(__dir__, '..'))
path_bin = File.join(path_skippy, 'bin')
path_lib = File.join(path_skippy, 'lib')
path_lib_public = File.join(path_lib, 'public')
path_commands = File.join(path_skippy, 'commands')

debug 'Skippy Paths:'.cyan
debug "BIN: #{path_bin}".yellow
debug "LIB: #{path_lib}".yellow
debug "CMD: #{path_commands}".yellow


# Add the Skippy lib path to load path.

$LOAD_PATH << path_lib_public


# Load commands from Skippy and current project.

search_paths = [
  path_commands,
  Dir.pwd # TODO: Search for project root.
]


# TODO: Move this logic to a helper class.
def find_child_classes_of(parent_class)
  result = []
  ObjectSpace.each_object(Class) { |klass|
    next unless klass.ancestors.include?(parent_class)
    next if klass == parent_class
    result << klass
  }
  result
end

debug 'Search Paths:'.cyan
search_paths.each { |path|
  pattern = "#{path}/*.rb"
  debug pattern.yellow

  commands = Dir.glob(pattern)
  debug_p commands

  command_file = commands.find { |path|
    require path
  }
}

debug 'Commands:'.cyan
command_klasses = find_child_classes_of(Skippy::Console::Command)
debug_p command_klasses

commands = command_klasses.map { |klass| klass.new }

command = commands.find { |cmd| cmd.signature == command_name }
if command.nil?
  puts "Command '#{command_name}' not found".red
  exit
end

debug 'Command:'.cyan
debug command.signature.yellow
debug command.description.yellow

command.run
