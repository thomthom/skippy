require 'skippy/console/command'

module Skippy::Console
  class New < Command

    def initialize
      super
      @signature = 'new'
      @description = 'Creates a new Skippy project.'

      @colorized_output = true
      @namespace = 'Example::Default'
    end

    def run
      info 'Creating new project...'
      warning Dir.pwd
      error 'Not implemented'
      p @colorized_output
      puts "Namespace: #{@namespace}"
      p ARGV
    end

    # @param [OptionParser]
    def setup_options(options)
      options.on("--no-color", "Disable colorized output") do |color|
        @colorized_output = color
      end

      options.on("--namespace NAMESPACE", "The project namespace") do |namespace|
        @namespace = namespace
      end
    end

  end # class
end # module Skippy::Console
