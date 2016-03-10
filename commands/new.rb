require 'skippy/console/command'

module Skippy
  module Console
    class New < Command

      def initialize
        super
        @signature = 'new'
        @description = 'Creates a new Skippy project.'
      end

      def run
        info 'Creating new project...'
        warning Dir.pwd
        error 'Not implemented'
      end

    end # class
  end # module
end # module
