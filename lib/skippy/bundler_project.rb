require 'skippy/error'
require 'skippy/bundler_library_manager'

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

  attr_reader :libraries

  # @param [Pathname, String] path
  def initialize(path)
    require 'bundler' # TODO: Use autoload?

    @path = Pathname.new(path)
    @libraries = Skippy::BundlerLibraryManager.new(self)
    # @path = find_project_path(path) || Pathname.new(path)
    # @config = Skippy::Config.load(filename, defaults)
    # @libraries = Skippy::LibraryManager.new(self)
    # @modules = Skippy::ModuleManager.new(self)
  end

  # Returns a list of all the skippy library gems this project depends on.
  #
  # @return [Array<Gem::Specification, Bundler::StubSpecification>]
  def available_gems
    # https://github.com/rubygems/rubygems/blob/master/lib/rubygems/defaults.rb
    # https://github.com/rubygems/rubygems/blob/master/lib/rubygems.rb
    #
    # https://github.com/rubygems/rubygems/blob/e70216910fd97b45d33949a838a6efc0fd058793/lib/rubygems/specification.rb#L964-L968
    # https://github.com/rubygems/rubygems/blob/e70216910fd97b45d33949a838a6efc0fd058793/lib/rubygems/specification.rb#L816-L824
    # https://github.com/rubygems/rubygems/blob/e70216910fd97b45d33949a838a6efc0fd058793/lib/rubygems/specification.rb#L790-L795
    #
    # Gem::Specification.dirs
    # => ["C:/Users/Thomas/.gem/ruby/2.7.0/specifications", "C:/Ruby27-x64/lib/ruby/gems/2.7.0/specifications"]
    #
    # Gem::Specification.stubs_for('skippy').map { |spec| "#{spec.name} (#{spec.version})" }
    #
    # Gem::Specification.stubs.size
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
