module Skippy::Helpers
  module File

    # @param [Pathname]
    # @return [Array<Pathname>]
    def directories(pathname)
      return [] unless pathname.exist?
      pathname.children.select(&:directory?)
    end

  end
end
