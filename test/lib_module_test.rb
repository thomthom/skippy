require 'test_helper'
require 'skippy/lib_module'
require 'skippy/project'

class SkippyLibModuleTest < Skippy::Test::Fixture

  attr_reader :project

  def setup
    super
    use_fixture('project_with_lib')
    @project = Skippy::Project.new(work_path)
  end

  def test_that_it_can_load_module_info
    library = project.libraries.find_library('my-lib')
    module_path = library.path.join('modules', 'command.rb')
    lib_module = Skippy::LibModule.new(library, module_path)
    assert_equal(module_path, lib_module.path)
    assert_equal('command', lib_module.basename)
    assert_equal('my-lib/command', lib_module.name)
  end

  def test_that_it_fails_when_module_path_does_not_exist
    library = project.libraries.find_library('my-lib')
    assert_raises(Skippy::LibModule::ModuleNotFoundError) do
      Skippy::LibModule.new(library, './bogus/path')
    end
  end

end
