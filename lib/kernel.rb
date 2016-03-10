module Skippy
  module Console

    class KernelError < StandardError; end
    class CommandNotFoundError < KernelError; end

    class Kernel

      def initialize(options)
        @options = options
        @commands = load_commands(options)
      end

      def command(command_name)
        command = @commands.find { |cmd| cmd.signature == command_name }
        if command.nil?
          raise CommandNotFoundError, "Command '#{command_name}' not found"
        end
        command
      end

      protected

      def discover(paths)
        files = []
        paths.each { |path|
          pattern = "#{path}/*.rb"
          files.concat(Dir.glob(pattern))
        }
        files
      end

      def load_files(files)
        files.each { |file| require file }
      end

      def load_commands(options)
        paths = search_paths(options)
        files = discover(paths)
        load_files(files)
        command_klasses = find_child_classes_of(Skippy::Console::Command)
        command_klasses.map { |klass| klass.new }
      end

      def search_paths(options)
        [
          options[:paths][:commands],
          Dir.pwd # TODO: Search for project root.
        ]
      end

      private

      def find_child_classes_of(parent_class)
        # TODO: Might want to move this to a generic mix-in module.
        result = []
        ObjectSpace.each_object(Class) { |klass|
          next unless klass.ancestors.include?(parent_class)
          next if klass == parent_class
          result << klass
        }
        result
      end

    end # class
  end # module
end # module
