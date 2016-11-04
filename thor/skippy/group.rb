require 'thor/group'

require 'skippy/command'

module Skippy
  class Command::Group < Thor::Group

    def self.cli_printable_commands(all = true, subcommand = false)
      item = []
      item << cli_banner
      item << (desc ? "#{desc.gsub(/\s+/m, ' ')}" : "")
      [item]
    end

    protected

    def self.cli_banner
      #"(CLI-G) #{self_command.formatted_usage(self, false)}"
      "#{self_command.formatted_usage(self, false)}"
    end

  end
end
