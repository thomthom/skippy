require 'skippy/console/printer'

module Skippy
  module Console
    class Command

      include Printer

      attr_accessor :signature

      attr_accessor :description

      def run
        raise NotImplementedError
      end

    end # class
  end # class
end # module
