require 'skippy/error'

module Skippy

  class GemNotFoundError < Skippy::Error; end
  class LockFileMissing < Skippy::Error; end

end

class Skippy::BundlerProject

  # @param [Pathname, String] path
  def initialize(path)
    require 'bundler'

    @path = Pathname.new(path)
    # @path = find_project_path(path) || Pathname.new(path)
    # @config = Skippy::Config.load(filename, defaults)
    # @libraries = Skippy::LibraryManager.new(self)
    # @modules = Skippy::ModuleManager.new(self)
  end

  # @return [Array<Bundler::LazySpecification>]
  def dependencies
    # unless Bundler.definition.lockfile.exist?
    #   raise Skippy::LockFileMissing, Bundler.definition.lockfile
    # end

    # Bundler::LockfileError (You must use Bundler 2 or greater with this lockfile.)

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
      definition.locked_gems.specs.select { |spec|
        spec.name.start_with?('skippy-')
      }
    end
  ensure
    ENV["BUNDLE_GEMFILE"] = original
  end

  # @return [Array<Gem::Specification>]
  def gems
    # result = []
    dependencies.map { |dependency|
      # p [:dep, dependency.name, dependency.version]
      specs = Gem::Specification.find_all_by_name(dependency.name)
      # gem = specs.find { |spec| spec.version == dependency.version }
      gem = specs.find { |spec|
        # p [:version, spec.version, dependency.version, spec.version == dependency.version]
        spec.version == dependency.version
      }
      gem or raise Skippy::GemNotFoundError, "#{dependency.name} (#{dependency.version})"
      # gem or raise Skippy::GemNotFoundError, dependency.full_name
      # gem = specs.last
      # result << gem if gem
    }
    # result
  end

end
