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

  def spesification_stub(name, version)
    Gem::Specification.new(name, Gem::Version.new(version))
  end

  def spesification_stubs
    [
      spesification_stub('example-gem', '2.5.6'),
      spesification_stub('skippy-example', '0.6.1'),
      spesification_stub('skippy-ex-lib', '1.2.3'),
      spesification_stub('skippy-dep-lib', '4.5.6'),
      spesification_stub('skippy', '0.4.0'),
    ]
  end

  def find_all_by_name_stub
    # puts [:def_find_all_by_name_stub, name]
    Proc.new do |name|
      # puts [:find_all_by_name_stub, name]
      spesification_stubs.select { |spesification|
        spesification.name == name
      }
    end
  end


  def test_that_it_can_list_available_project_libraries
    skip
    use_fixture('project_with_lib')

    bundler_project = Skippy::BundlerProject.new(work_path)
    # assert_equal(2, bundler_project.dependencies.size)
    dependencies = bundler_project.dependencies
    # p dependencies.first.class

    dependencies.each { |dependency|
      assert_kind_of(Bundler::LazySpecification, dependency)
    }

    names = dependencies.map(&:name).sort
    expected = %w[
      skippy-ex-lib
      skippy-example
    ]
    assert_equal(expected, names)

    full_names = dependencies.map(&:full_name).sort
    expected = %w[
      skippy-ex-lib-1.2.3
      skippy-example-0.6.1
    ]
    assert_equal(expected, full_names)

    versions = dependencies.map(&:version).sort
    expected = [
      Gem::Version.new('0.6.1'),
      Gem::Version.new('1.2.3'),
    ]
    assert_equal(expected, versions)
  end

  def test_that_it_can_list_available_global_libraries
    skip('TODO')
    # TODO:
  end

  def test_that_it_can_list_available_project_gems
    use_fixture('project_with_lib')

    # gems = nil
    gems = Gem::Specification.stub(:find_all_by_name, find_all_by_name_stub) do
      bundler_project = Skippy::BundlerProject.new(work_path)
      # gems = bundler_project.gems
      bundler_project.gems
    end

    gems.each { |gem|
      assert_kind_of(Gem::Specification, gem)
    }

    gems.each { |gem|
      puts "#{gem.name} - #{gem.version} (#{gem.full_gem_path})"
    }

    # p [:gems, gems.map(&:name), gems.map(&:version)]
    # p [:gems, gems.map(&:full_gem_path)] # Check that path exists.
    # TODO: Use gem_dir? (See basic_specification.rb)
    # In the stubs - set the full_gem_path to the fixture path?
    # TODO: Test nested dependencies
  end

end
