module Skippy
  module Console
    class Command

      attr_accessor :signature

      attr_accessor :description

      def run
        raise NotImplementedError
      end

    end # class
  end # class
end # module
