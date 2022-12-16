require 'skippy/error'

module Skippy

  class GemNotFoundError < Skippy::Error; end
  class LockFileMissing < Skippy::Error; end

end

class Skippy::BundlerProject

  # https://stackoverflow.com/a/40098825
  # https://willschenk.com/articles/2020/looking_at_gemfiles/

  # class LockFileParser < Bundler::LockfileParser
  #   attr_reader :sources, :dependencies, :specs, :platforms, :bundler_version, :ruby_version
  # end

  # @param [Pathname, String] path
  def initialize(path)
    require 'bundler'

    @path = Pathname.new(path)
    # @path = find_project_path(path) || Pathname.new(path)
    # @config = Skippy::Config.load(filename, defaults)
    # @libraries = Skippy::LibraryManager.new(self)
    # @modules = Skippy::ModuleManager.new(self)
  end

  # Returns the direct dependencies of the project defined in `Gemfile`.
  # This does not include nested dependencies.
  #
  # @return [Array<Bundler::LazySpecification>]
  def dependencies
    # unless Bundler.definition.lockfile.exist?
    #   raise Skippy::LockFileMissing, Bundler.definition.lockfile
    # end

    # Bundler::LockfileError (You must use Bundler 2 or greater with this lockfile.)

    lock_file = @path.join('Gemfile.lock')
    context = Bundler::LockfileParser.new(Bundler.read_file(lock_file))

    # When running the tests in this project via `bundler exec` the
    # ENV["BUNDLE_GEMFILE"] will be set to the Gemfile of skippy - not the
    # test project.
    original = ENV["BUNDLE_GEMFILE"]
    ENV.delete("BUNDLE_GEMFILE")
    Dir.chdir(@path.to_s) do
      # puts Bundler.definition.lockfile
      # Bundler.definition.locked_gems.specs

      default_gemfile = Bundler.default_gemfile
      default_lockfile = Bundler.default_lockfile
      unlock = nil # Don't unlock.
      # puts ENV["BUNDLE_GEMFILE"]
      # puts Bundler::SharedHelpers.default_gemfile
      # puts Bundler::SharedHelpers.default_lockfile
      # TODO: This doesn't configure Bundler. Load paths, etc. Investigate if this causes problems.
      # Only need to get list of gems used (Gemfile.locked).
      definition = Bundler::Definition.build(default_gemfile, default_lockfile, unlock)
      p [:locked_gems_specs, definition.locked_gems.specs.map(&:name)]
      p [:locked_gems_dependencies, definition.locked_gems.dependencies]
      # p [:requested_specs, definition.requested_specs.map(&:name)]
      # p [:missing_specs, definition.missing_specs.map(&:name)]
      # p [:specs, definition.specs.map(&:name)]
      definition.locked_gems.specs.select { |spec|
        spec.name.start_with?('skippy-')
      }
    end
  ensure
    ENV["BUNDLE_GEMFILE"] = original
  end

  # Returns a list of all the skippy library gems this project depends on.
  #
  # @return [Array<Gem::Specification>]
  def gems
    # puts
    # puts @path
    # puts Dir.glob("#{@path}/*").join("\n")

    lockfile_path = File.join(@path, 'Gemfile.lock')
    lockfile = Bundler.read_file(lockfile_path)
    parser = Bundler::LockfileParser.new(lockfile)

    gem_specs = [] # The project's gem specs.
    parser.specs.each { |bundle_spec|
      # All skippy lib gems must start with 'skippy-'.
      next unless bundle_spec.name.start_with?('skippy-')

      # Find the spec for the given spec an version
      specs = Gem::Specification.find_all_by_name(bundle_spec.name)
      gem = specs.find { |spec|
        spec.version == bundle_spec.version
      }
      gem or raise Skippy::GemNotFoundError, "#{bundle_spec.name} (#{bundle_spec.version})"

      gem_spec = specs.last
      gem_specs << gem_spec

      # Check dependencies.
      # TODO: Might be nested dependecies.
      bundle_spec.dependencies.each { |dependency|
        next unless dependency.name.start_with?('skippy-')

        specs = Gem::Specification.find_all_by_name(dependency.name)
        gem_dep = specs.find { |spec|
          dependency.matches_spec?(spec)
        }
        gem_dep or raise Skippy::GemNotFoundError, "#{dependency.name} (#{dependency.version})"
        gem_specs << gem_dep
      }
    }
    puts
    gem_specs.sort! { |a, b| a.name <=> b.name }
    gem_specs
  end

end
