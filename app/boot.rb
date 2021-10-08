#!/usr/bin/env ruby
# frozen_string_literal: true

# Set the program name explicitly. Otherwise Thor will use the filename in the
# banner for the command help.
$PROGRAM_NAME = 'skippy'

# TODO(thomthom): Temporary set for development without having to set the ENV.
# Thor on Windows will by default not use colors. Using Cmder colors will work.
# Also in the latest Windows 10 colors appear to work. Not sure how older
# versions behave.
ENV['THOR_SHELL'] = 'Color' if $stdout.isatty

# Thor require DL which under Windows and Ruby 2.0 will yield a warning:
#   DL is deprecated, please use Fiddle
#
# To avoid this appearing every time this tool is invoked, warnings are
# temporarily suppressed.
begin
  original_verbose = $VERBOSE
  $VERBOSE = nil
  require 'thor'
  # The Thor::Runner also needs to be loaded, as Skippy::CLI will call many of
  # of the same methods - in many cases emulating what it do.
  require 'thor/runner'
  # This is also needed to be set in order for Thor's utilities to output
  # command names correctly.
  $thor_runner = true # rubocop:disable Style/GlobalVars
ensure
  $VERBOSE = original_verbose
end

# Load skippy components the bootstrapper needs.
require 'skippy/app'
Skippy::App.boot(__FILE__)

# Everything is ready to start the CLI.
require 'skippy/cli'
require 'skippy/error'
begin
  Skippy::CLI.start
rescue Skippy::Error => error
  Skippy::CLI.display_error(error)
end
