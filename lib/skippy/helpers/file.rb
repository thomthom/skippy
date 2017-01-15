module Skippy::Helpers
  module File

    # @param [Pathname]
    # @return [Array<Pathname>]
    def directories(pathname)
      pathname.children.select { |child|
        child.directory?
      }
    end

  end
end
