require 'thor/group'

require 'skippy/command'

module Skippy
  class Command::Group < Thor::Group

    protected

    # Customize the banner as we don't care for the 'skippy' prefix for each
    # item in the list.
    def self.banner
      "#{self_command.formatted_usage(self, false)}"
    end

  end
end
