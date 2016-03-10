module Skippy
  module Console
    module Printer

      def info(text)
        puts text.cyan
      end

      def warning(text)
        puts text.yellow
      end

      def error(text)
        puts text.white.on_red
      end

    end # module
  end # class
end # module
