module Skippy
  class Debug

    def initialize(enabled = false)
      @enabled = enabled
    end

    def puts(*args)
      ::Kernel.puts *args if @enabled
    end

    def p(*args)
      ::Kernel.p *args if @enabled
    end

  end # class
end # module
