module Skippy
  module Console
    module Printer

      def info(text)
        $stdout.puts text.cyan
      end

      def warning(text)
        $stderr.puts text.yellow
      end

      def error(text)
        $stderr.puts pad_text_block(text).white.on_red
      end

      private

      def pad_text_block(text)
        return text if text.empty?
        lines = text.lines
        width = lines.max { |line| line.size }.size
        lines.map! { |line|
          "  #{line.ljust(width, ' ')}  "
        }
        padding = ' ' * (width + 4)
        lines.unshift(padding)
        lines.unshift('')
        lines.push(padding)
        lines.push('')
        lines.join("\n")
      end

    end # module
  end # class
end # module
