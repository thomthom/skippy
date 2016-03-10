require 'skippy/command'

module Skippy
  module Console
    class New < Command

      def initialize
        super
        @signature = 'new'
        @description = 'Creates a new Skippy project.'
      end

      def run
        puts "Creating new project...".cyan
        puts Dir.pwd.yellow
      end

    end # class
  end # module
end # module
