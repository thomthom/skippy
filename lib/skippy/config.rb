module Skippy
  class Config

    attr_reader :path_app, :path_bin, :path_lib, :path_commands

    def initialize(lib_path)
      @path_app = File.expand_path(File.join(lib_path, '..'))
      @path_bin = File.join(@path_app, 'bin')
      @path_lib = File.join(@path_app, 'lib')
      @path_commands = File.join(@path_app, 'commands')
    end

  end # class
end # module
