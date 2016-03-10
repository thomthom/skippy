module Skippy
  module Console
    class Command

      attr_accessor :signature

      attr_accessor :description

      def initialize
      end

      def run
        puts  "#{self}.run"
      end

    end # class
  end # class
end # module
