require 'skippy/error'

module Skippy

  class GemNotFoundError < Skippy::Error; end
  class LockFileMissing < Skippy::Error; end

end

class Skippy::BundlerProject

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

  # @return [Array<Gem::Specification>]
  def gems
    # specs = Bundler.definition.locked_gems.specs
    # p dependencies.map(&:full_name)
    # p dependencies
    puts JSON.pretty_generate(dependencies)

    puts
    # default_lockfile = Bundler.default_lockfile
    puts @path
    puts Dir.glob("#{@path}/*").join("\n")
    # default_lockfile = Dir.chdir(@path.to_s) do
    #   Bundler.default_lockfile
    # end
    # puts default_lockfile
    # lockfile = File.read(default_lockfile)
    lockfile_path = File.join(@path, 'Gemfile.lock')
    puts lockfile_path
    lockfile = File.read(lockfile_path)
    parser = Bundler::LockfileParser.new(lockfile)
    # p parser.specs
    gem_specs = []
    parser.specs.each { |bundle_spec|
      # puts "bundle_spec: #{bundle_spec.name}"
      next unless bundle_spec.name.start_with?('skippy-')

      # p [:dep, dependency.name, dependency.version]
      specs = Gem::Specification.find_all_by_name(bundle_spec.name)
      # gem = specs.find { |spec| spec.version == dependency.version }
      # TODO: find best match based on Bundle requirements.
      gem = specs.find { |spec|
        # p [:version, spec.version, dependency.version, spec.version == dependency.version]
        spec.version == bundle_spec.version
      }
      gem or raise Skippy::GemNotFoundError, "#{bundle_spec.name} (#{bundle_spec.version})"
      # gem or raise Skippy::GemNotFoundError, dependency.full_name
      gem_spec = specs.last
      gem_specs << gem_spec

      bundle_spec.dependencies.each { |dependency|
        next unless dependency.name.start_with?('skippy-')
        # puts "  dependency: #{dependency.name}"
        specs = Gem::Specification.find_all_by_name(dependency.name)
        # TODO: find best match based on Bundle requirements.
        # gem = specs.find { |spec|
        #   spec.version == dependency.version
        # }
        gem or raise Skippy::GemNotFoundError, "#{dependency.name} (#{dependency.version})"
        gem = specs.last

        gem_specs << gem
      }
    }
    puts
    gem_specs.sort! { |a, b| a.name <=> b.name }
    gem_specs

=begin
    # result = []
    dependencies.map { |dependency|
      # p [:dep, dependency.name, dependency.version]
      specs = Gem::Specification.find_all_by_name(dependency.name)
      # gem = specs.find { |spec| spec.version == dependency.version }
      # TODO: find best match based on Bundle requirements.
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
=end
  end

end
