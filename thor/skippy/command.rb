require 'thor'

module Skippy
  class Command < Thor

    protected

    # Customize the banner as we don't care for the 'skippy' prefix for each
    # item in the list.
    def self.banner(command, namespace = nil, subcommand = false)
      "#{command.formatted_usage(self, true, subcommand)}"
    end

  end
end
