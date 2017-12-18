module Skippy::Helpers
  module File

    extend self

    # @param [Pathname]
    # @return [Array<Pathname>]
    def directories(pathname)
      return [] unless pathname.exist?
      pathname.children.select(&:directory?)
    end

  end
end
