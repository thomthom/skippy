# p ARGV
# p $LOAD_PATH

# $LOAD_PATH << File.join(__dir__) # TODO: temp debug!
# require 'Bundler'
# Bundler.setup


# class Object
#   def methods!
#     methods.sort - Object.methods
#   end
# end
# class Object; def methods!; methods.sort - Object.methods; end; end


require 'test_helper'
require 'skippy/bundler_project'
# require 'skippy/library_manager'
# require 'skippy/lib_module'
# require 'skippy/project'

class SkippyBundlerProjectTest < Skippy::Test::Fixture

  class SpecificationStub < Gem::Specification

    ##
    # Returns the full path to the gems directory containing this spec's
    # gem directory. eg: /usr/local/lib/ruby/1.8/gems
    def gems_dir
      # https://github.com/rubygems/rubygems/blob/aabb00d9b5a30aa4243f74644b527426d4c6f287/lib/rubygems/basic_specification.rb#L200
      # TODO: Should this be a temp copy?
      # TODO: Reuse the instance methods from Skippy::Test.
      Pathname.new(__dir__).parent.join('fixtures', 'ruby-gems', 'gems')
    end

  end

  # @param [String] name
  # @param [String] version
  # @return [Array<SpecificationStub>]
  def specification_stub(name, version)
    SpecificationStub.new(name, Gem::Version.new(version))
  end

  # To avoid needing to install gems, this method can be used to return stubs
  # for installed extensions.
  #
  # @example
  #   gems = Gem::Specification.stub(:find_all_by_name, find_all_by_name_stub) do
  #     bundler_project = Skippy::BundlerProject.new(work_path)
  #     # gems = bundler_project.gems
  #     bundler_project.gems
  #   end
  #
  # @return [Array<Gem::Specification>]
  def specification_stubs
    [
      specification_stub('example-gem', '2.5.6'),
      specification_stub('skippy-example', '0.6.1'),
      specification_stub('skippy-ex-lib', '1.2.3'),
      specification_stub('skippy-dep-lib', '4.5.6'),
      specification_stub('skippy', '0.4.0'),
    ]
  end

  def fixture_gem_stubs
    base_dir = Pathname.new(__dir__).parent.join('fixtures', 'ruby-gems')
    gems_dir = base_dir.join('gems')
    spec_dir = base_dir.join('specifications')
    pattern = spec_dir.join('*.gemspec').to_s
    Dir.glob(pattern).map { |path|
      # https://www.rubydoc.info/github/rubygems/rubygems/Gem/StubSpecification#initialize-instance_method
      Gem::StubSpecification.new(path, base_dir.to_s, gems_dir.to_s, false)
    }
  end

  # Stub replacement for Gem::Specification#each
  def each_specification_stubs
    proc do |&block|
      fixture_gem_stubs.each { |spec| block.call(spec) }
    end
  end

  # Stub replacement for Gem::Specification#find_all_by_name
  def find_all_by_name_stub
    # puts [:def_find_all_by_name_stub, name]
    proc do |name|
      # puts [:find_all_by_name_stub, name]
      specification_stubs.select { |spesification|
        spesification.name == name
      }
    end
  end


  def test_that_it_can_list_available_global_libraries
    skip('TODO')
    # TODO:
  end

  def test_that_it_can_list_available_project_libraries
    # TODO: This should be part of LibraryManager.
    use_fixture('project_with_lib')

    libs = Gem::Specification.stub(:find_all_by_name, find_all_by_name_stub) do
      bundler_project = Skippy::BundlerProject.new(work_path)
      bundler_project.libraries.to_a
    end

    libs.each { |lib|
      assert_kind_of(Skippy::Library, lib)
    }

    # Only expect direct dependencies. If the project want to use a
    # sub-dependency that should be declared explicitly and not be relied on
    # implicitly.
    data = {}
    libs.each { |lib| data[lib.name] = lib }
    expected = [
      ['ex-lib', '1.2.3'],
      ['example-lib', '0.6.1'],
    ]
    expected.each { |name, version|
      gem = data[name]
      refute_nil(gem, "Unable to find expected library: #{name}")
      assert_equal(name, gem.name)
      assert_equal(version, gem.version.to_s)
    }
    assert_equal(expected.size, libs.size)
  end

  def test_that_it_can_list_used_project_library_modules
    skip('TODO')
    # TODO:
  end

  def test_that_it_can_list_available_global_gems
    use_fixture('project_with_lib')

    bundler_project = Gem::Specification.stub(:find_all_by_name, find_all_by_name_stub) do
      Skippy::BundlerProject.new(work_path)
    end
    gems = Gem::Specification.stub(:each, each_specification_stubs) do
      bundler_project.available_gems
    end

    # Might be Bundler::StubSpecification (?) or Gem::StubSpecification
    # gems.each { |gem|
    #   assert_kind_of(Gem::Specification, gem)
    # }

    data = {}
    gems.each { |gem| data[gem.full_name] = gem }
    expected = [
      ['skippy-dep-lib', '4.5.6', true],
      ['skippy-dep-lib', '5.2.1', true],
      ['skippy-ex-lib', '1.2.3', true],
      ['skippy-example', '0.6.1', true],
      ['skippy-other-lib', '4.5.6', true],
    ]
    expected.each { |name, version, exists|
      full_name = "#{name}-#{version}"
      gem = data[full_name]
      refute_nil(gem, "Unable to find expected gem: #{name}")
      assert_equal(name, gem.name)
      assert_equal(version, gem.version.to_s)
      assert_equal(exists, File.directory?(gem.gem_dir))
    }
    assert_equal(expected.size, gems.size)
  end

  def test_that_it_can_list_direct_gem_dependencies
    use_fixture('project_with_lib')

    gems = Gem::Specification.stub(:find_all_by_name, find_all_by_name_stub) do
      bundler_project = Skippy::BundlerProject.new(work_path)
      bundler_project.dependencies
    end

    gems.each { |gem|
      assert_kind_of(Gem::Specification, gem)
    }

    data = {}
    gems.each { |gem| data[gem.name] = gem }
    expected = [
      ['skippy-ex-lib', '1.2.3', true],
      ['skippy-example', '0.6.1', true],
    ]
    expected.each { |name, version, exists|
      gem = data[name]
      refute_nil(gem, "Unable to find expected gem: #{name}")
      assert_equal(name, gem.name)
      assert_equal(version, gem.version.to_s)
      assert_equal(exists, File.directory?(gem.gem_dir))
    }
    assert_equal(expected.size, gems.size)
  end

  def test_that_it_can_list_all_gem_dependencies
    use_fixture('project_with_lib')

    gems = Gem::Specification.stub(:find_all_by_name, find_all_by_name_stub) do
      bundler_project = Skippy::BundlerProject.new(work_path)
      bundler_project.dependencies(nested: true)
    end

    gems.each { |gem|
      assert_kind_of(Gem::Specification, gem)
    }

    data = {}
    gems.each { |gem|
      # exists = File.directory?(gem.gem_dir) ? 'EXISTS' : 'MISSING'
      # puts "#{gem.name} - #{gem.version} (#{gem.gem_dir} - #{exists})"
      data[gem.name] = gem
    }
    expected = [
      ['skippy-dep-lib', '4.5.6', true],
      ['skippy-ex-lib', '1.2.3', true],
      ['skippy-example', '0.6.1', true],
    ]
    expected.each { |name, version, exists|
      gem = data[name]
      refute_nil(gem, "Unable to find expected gem: #{name}")
      assert_equal(name, gem.name)
      assert_equal(version, gem.version.to_s)
      assert_equal(exists, File.directory?(gem.gem_dir))
    }
    assert_equal(expected.size, gems.size)

    # TODO: Check nested dependencies.
  end

end
