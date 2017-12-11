require 'test_helper'
require 'skippy/module_manager'
require 'skippy/project'

class SkippyModuleManagerTest < Skippy::Test::Fixture

  attr_reader :project

  def test_that_it_can_use_module
    use_fixture('my_project')
    project = Skippy::Project.new(work_path)
    library_source = fixture('my_lib')
    project.libraries.install(library_source)
    assert_empty(project.modules)

    result = project.modules.use('my-lib/gl')

    assert_kind_of(Skippy::LibModule, result)

    assert_equal(1, project.modules.size)
    assert_directory(project.path('src/hello_world/vendor/my-lib'))
    assert_file(project.path('src/hello_world/vendor/my-lib/gl.rb'))
    assert_file(project.path('src/hello_world/vendor/my-lib/gl/container.rb'))
    assert_file(project.path('src/hello_world/vendor/my-lib/gl/control.rb'))
  end

  def test_that_it_can_remove_a_module
    use_fixture('project_with_lib')
    project = Skippy::Project.new(work_path)
    project.modules.use('my-lib/gl')
    assert_equal(3, project.modules.size)

    result = project.modules.remove('my-lib/gl')

    assert_kind_of(Skippy::LibModule, result)

    assert_equal(2, project.modules.size)
    assert_directory(project.path('src/hello_world/vendor/my-lib'))
    refute_file(project.path('src/hello_world/vendor/my-lib/gl.rb'))
    refute_file(project.path('src/hello_world/vendor/my-lib/gl/container.rb'))
    refute_file(project.path('src/hello_world/vendor/my-lib/gl/control.rb'))
  end

end
