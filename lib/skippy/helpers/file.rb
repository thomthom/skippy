module Skippy::Helpers
  module File

    # @param [Pathname]
    # @return [Array<Pathname>]
    def directories(pathname)
      return [] unless pathname.exist?
      pathname.children.select { |child|
        child.directory?
      }
    end

  end
end
