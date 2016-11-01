#!/usr/bin/env ruby

# Set the program name explicitly. Otherwise Thor will use the filename in the
# banner for the command help.
$PROGRAM_NAME = 'skippy'

# TODO(thomthom): Temporary set for development without having to set the ENV.
# Thor on Windows will by default not use colors. Using Cmder colors will work.
# Also in the latest Windows 10 colors appear to work. Not sure how older
# versions behave.
ENV['THOR_SHELL'] = 'Color' if $stdout.isatty

# Thor require DL which under Windows will yield a warning:
#   DL is deprecated, please use Fiddle
#
# To avoid this appearing every time this tool is invoked, warnings are
# temporarily suppressed.
begin
  original_verbose = $VERBOSE
  $VERBOSE = nil
  require 'thor'
ensure
  $VERBOSE = original_verbose
end

# Setup the load path to include Skippy's required files.
path_lib = File.join(__dir__)
$LOAD_PATH << path_lib

# Load the default skippy commands.
path_commands = File.join(__dir__, 'commands')
commands_pattern = File.join(path_commands, '*.rb')
Dir.glob(commands_pattern) { |filename|
  require filename
}

# Load the custom skippy commands.
# TODO(thomthom): Make the current project availible to the rest of the app.
project = Skippy::Project.new(Dir.pwd)
if project.exist?
  # TODO(thomthom): Currently searching recursivly. This might not be best thing
  # to do. Maybe it's better to load only the base directory and let those files
  # take care of loading from the sub-folders if needed.
  files_pattern = File.join(project.path, 'skippy', '**', '*.rb')
  Dir.glob(files_pattern) { |filename|
    require filename
  }
end

# Everything is ready to start the CLI.
begin
  Skippy::CLI.start
rescue Skippy::Error => error
  shell = Thor::Base.shell.new
  message = " #{error.message} "
  message = shell.set_color(message, :white)
  message = shell.set_color(message, :on_red)
  shell.error message
end
