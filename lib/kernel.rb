module Skippy
  module Console

    class KernelError < StandardError; end
    class CommandNotFoundError < KernelError; end

    class Kernel

      # @param [Hash] options
      def initialize(options)
        @options = options
        @commands = load_commands(options)
      end

      # @param [String] command_name
      #
      # @return [Skippy::Console::Command]
      def command(command_name)
        command = @commands.find { |cmd| cmd.signature == command_name }
        if command.nil?
          raise CommandNotFoundError, "Command '#{command_name}' not found"
        end
        command
      end

      private

      # @param [Array<String>] paths
      #
      # @return [Array<String>] List of Ruby files in the paths.
      def discover(paths)
        files = []
        paths.each { |path|
          pattern = "#{path}/*.rb"
          files.concat(Dir.glob(pattern))
        }
        files
      end

      # @param [Array<String>] files
      #
      # @return [nil]
      def load_files(files)
        files.each { |file| require file }
        nil
      end

      # @param [Hash] options
      #
      # @return [Array<Skippy::Console:Command>]
      def load_commands(options)
        paths = search_paths(options)
        files = discover(paths)
        load_files(files)
        command_klasses = find_child_classes_of(Skippy::Console::Command)
        command_klasses.map { |klass| klass.new }
      end

      # @param [Hash] options
      #
      # @return [Array<String>]
      def search_paths(options)
        [
          options[:paths][:commands],
          Dir.pwd # TODO: Search for project root.
        ]
      end

      # @param [Class] parent_class
      #
      # @return [Array<Class>]
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
