require 'skippy/library_manager'

class Skippy::BundlerLibraryManager < Skippy::LibraryManager

  private

  # @return [Array<Skippy::Library>]
  def discover_libraries
    project.dependencies.map { |gem_spec|
      begin
        # library_from_config(lib_config)
        directory = gem_spec.gem_dir
        # TODO: Remove LibrarySource?
        # source = Skippy::LibrarySource.new(project, config[:source])
        source = Skippy::LibrarySource.new(project, directory)
        library = Skippy::Library.new(directory, source: source)
      rescue Skippy::Library::LibraryNotFoundError => error
        # TODO: Revisit how to handle this.
        warn "Unable to load library: #{error.message}"
        warn "Project: #{project.path}"
        warn lib_config.inspect
        nil
      end
    }.compact
  end

end
