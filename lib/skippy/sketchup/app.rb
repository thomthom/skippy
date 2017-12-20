module Skippy

  SketchUpApp = Struct.new(:executable, :version, :can_debug, :is64bit) do

    def self.from_hash(hash)
      new(*hash.values_at(*members))
    end

  end

end
