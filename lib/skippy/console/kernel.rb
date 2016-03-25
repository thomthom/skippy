require 'optparse'

require 'skippy/console/command'
require 'skippy/console/printer'

module Skippy
  module Console

    class KernelError < StandardError; end
    class CommandNotFoundError < KernelError; end

    class Kernel

      include Printer

      # @param [Skippy::Config] config
      def initialize(config)
        @config = config
        @commands = load_commands(config)
      end

      # @param [String] command_name
      #
      # @return [Skippy::Console::Command]
      def command(command_name)
        command = @commands.find { |cmd| cmd.signature == command_name }
        if command.nil?
          raise CommandNotFoundError, "Command '#{command_name}' not found"
        end
        init_options(command)
        command
      end

      private

      # @param [Skippy::Console::Command] command
      def init_options(command)
        option_parser = OptionParser.new do |options|
          message = "Usage: #{command.signature}\n".cyan
          message << command.description.yellow
          options.set_banner(message)

          options.separator("")
          options.separator("Options:")

          command.setup_options(options)

          options.on_tail("-h", "--help", "Display command usage helps") do
            $stderr.puts options.help
            exit 1
          end
        end
        begin
          option_parser.parse!
        rescue OptionParser::InvalidOption => error
          error "ERROR: #{error.message}"
          $stderr.puts option_parser.help
          exit 1
          # TODO: List command help?
        end
        nil
      end

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

      # @param [Skippy::Config] config
      #
      # @return [Array<Skippy::Console:Command>]
      def load_commands(config)
        paths = search_paths(config)
        files = discover(paths)
        load_files(files)
        command_klasses = find_child_classes_of(Skippy::Console::Command)
        command_klasses.map { |klass| klass.new }
      end

      # @param [Skippy::Config] config
      #
      # @return [Array<String>]
      def search_paths(config)
        [
          config.path_commands,
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
