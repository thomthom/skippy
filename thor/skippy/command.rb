require 'thor'

#require 'skippy/thor_ext'

module Skippy
  class Command < Thor

    def self.cli_printable_commands(all = true, subcommand = false)
      (all ? all_commands : commands).map do |_, command|
        next if command.hidden?
        item = []
        #item << banner(command, false, subcommand)
        item << cli_banner(command, false, subcommand)
        item << (command.description ? "#{command.description.gsub(/\s+/m, ' ')}" : "")
        item
      end.compact
    end

    protected

    def self.cli_banner(command, namespace = nil, subcommand = false)
      #"(CLI) #{command.formatted_usage(self, $thor_runner, subcommand)}"
      "#{command.formatted_usage(self, $thor_runner, subcommand)}"
    end

  end
end
