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

  # Returns a list of all the skippy library gems this project depends on.
  #
  # @return [Array<Gem::Specification, Bundler::StubSpecification>]
  def available_gems
    Gem::Specification.select { |spec| spec.name.start_with?('skippy-') }
  end

  # Returns a list of all the skippy library gems this project depends on.
  #
  # @return [Array<Gem::Specification>]
  def dependencies(nested: false)
    # puts
    # puts @path
    # puts Dir.glob("#{@path}/*").join("\n")

    lockfile_path = @path.join('Gemfile.lock')
    unless lockfile_path.exist?
      raise Skippy::LockFileMissing, lockfile_path
    end

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

      next unless nested

      # Check dependencies.
      # TODO: Might be nested dependencies.
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
    gem_specs.sort! { |a, b| a.name <=> b.name }
    gem_specs
  end

end
