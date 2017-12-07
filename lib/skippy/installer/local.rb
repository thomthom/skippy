require 'pathname'

require 'skippy/installer'
require 'skippy/library'

class Skippy::LocalLibraryInstaller < Skippy::LibraryInstaller

  # @return [Skippy::Library]
  def install
    info "Installing #{source.basename} from #{source.origin}..."
    library = Skippy::Library.new(source.origin)
    target = path.join(library.name)
    FileUtils.mkdir_p(path)
    FileUtils.copy_entry(source.origin, target)
    Skippy::Library.new(target)
  end

end
