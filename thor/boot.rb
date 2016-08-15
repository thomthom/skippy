#!/usr/bin/env ruby

# Set the program name explicitly. Otherwise Thor will use the filename in the
# banner for the command help.
$PROGRAM_NAME = 'skippy'


# TODO: Temporary to debugging without having to set the ENV.
ENV["THOR_SHELL"] = 'Color'


# Thor require DL which under Windows will yield a warning:
#   DL is deprecated, please use Fiddle
#
# To avoid this appearing every time this tool is invoked warnings is
# temporarily suppressed.
begin
  original_verbose = $VERBOSE
  $VERBOSE = nil
  require "thor"
ensure
  $VERBOSE = original_verbose
end


# Setup the load path.
path_lib = File.join(__dir__)
$LOAD_PATH << path_lib


# Load the default skippy commands.
path_commands = File.join(__dir__, 'commands')
commands_pattern = File.join(path_commands, '*.rb')
Dir.glob(commands_pattern) { |filename|
  require filename
}


# Load the custom skippy commands.
project_path = Dir.pwd # TODO: Find project root. (skippy.json)
files_pattern = File.join(project_path, 'skippy', '**' '*.rb')
Dir.glob(files_pattern) { |filename|
  require filename
}

  Skippy::CLI.start
