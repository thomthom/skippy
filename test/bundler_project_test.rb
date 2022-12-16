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
      Pathname.new(__dir__).parent.join('fixtures', 'gems')
    end

  end

  # @param [String] name
  # @param [String] version
  # @return [Array<SpecificationStub>]
  def spesification_stub(name, version)
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
  def spesification_stubs
    [
      spesification_stub('example-gem', '2.5.6'),
      spesification_stub('skippy-example', '0.6.1'),
      spesification_stub('skippy-ex-lib', '1.2.3'),
      spesification_stub('skippy-dep-lib', '4.5.6'),
      spesification_stub('skippy', '0.4.0'),
    ]
  end

  # Stub replacement for Gem::Specification#find_all_by_name
  def find_all_by_name_stub
    # puts [:def_find_all_by_name_stub, name]
    Proc.new do |name|
      # puts [:find_all_by_name_stub, name]
      spesification_stubs.select { |spesification|
        spesification.name == name
      }
    end
  end


  def test_that_it_can_list_available_global_libraries
    skip('TODO')
    # TODO:
  end

  def test_that_it_can_list_available_project_libraries
    skip('TODO')
    # TODO:
  end

  def test_that_it_can_list_available_global_gems
    skip('TODO')
    # TODO:
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
      refute_nil(gem)
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
      refute_nil(gem)
      assert_equal(name, gem.name)
      assert_equal(version, gem.version.to_s)
      assert_equal(exists, File.directory?(gem.gem_dir))
    }
    assert_equal(expected.size, gems.size)

    # TODO: Check nested dependencies.
  end

end
