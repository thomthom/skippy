
module Debug

  @debug = true

  def self.puts(*args)
    Kernel.puts *args if @debug
  end

  def self.p(*args)
    Kernel.p *args if @debug
  end

end # module


# Short syntax.

def debug(*args)
  Debug.puts(*args)
end

def debug_p(*args)
  Debug.p(*args)
end
