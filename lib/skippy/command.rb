# frozen_string_literal: true

require 'thor'

module Skippy
  class Command < Thor

    # Customize the banner as we don't care for the 'skippy' prefix for each
    # item in the list.
    def self.banner(command, _namespace = nil, subcommand = false)
      command.formatted_usage(self, true, subcommand).to_s
    end

    def self.exit_on_failure?
      # https://github.com/rails/thor/issues/244
      true
    end

  end
end
