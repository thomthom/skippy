# frozen_string_literal: true
require 'test_helper'
require 'skippy/library_manager'
require 'skippy/lib_module'
require 'skippy/project'

class SkippyLibraryManagerTest < Skippy::Test::Fixture

  def test_that_it_can_install_library
    use_fixture('my_project')
    project = Skippy::Project.new(work_path)
    library_source = fixture('my_lib')
    assert_empty(project.libraries)
    refute_directory(project.path('.skippy/libs/my-lib'))

    result = project.libraries.install(library_source)

    assert_kind_of(Skippy::Library, result)

    assert_equal(1, project.libraries.size)
    assert_directory(project.path('.skippy/libs/my-lib'))
    assert_file(project.path('.skippy/libs/my-lib/skippy.json'))
    assert_file(project.path('.skippy/libs/my-lib/modules/command.rb'))
    assert_file(project.path('.skippy/libs/my-lib/modules/geometry.rb'))
    assert_file(project.path('.skippy/libs/my-lib/modules/gl.rb'))
    assert_file(project.path('.skippy/libs/my-lib/modules/gl/control.rb'))
    assert_file(project.path('.skippy/libs/my-lib/modules/gl/container.rb'))
    assert_file(project.path('.skippy/libs/my-lib/modules/tool.rb'))
  end

  def test_that_it_can_uninstall_library
    use_fixture('project_with_lib')
    project = Skippy::Project.new(work_path)
    assert_equal(2, project.libraries.size)
    assert_directory(project.path('.skippy/libs/my-lib'))

    library = project.libraries.uninstall('my-lib')

    assert_kind_of(Skippy::Library, library)
    assert_equal('my-lib', library.name)

    assert_equal(1, project.libraries.size)
    refute_directory(project.path('.skippy/libs/my-lib'))
    refute_file(project.path('.skippy/libs/my-lib/skippy.json'))
    refute_file(project.path('.skippy/libs/my-lib/modules/command.rb'))
    refute_file(project.path('.skippy/libs/my-lib/modules/geometry.rb'))
    refute_file(project.path('.skippy/libs/my-lib/modules/gl.rb'))
    refute_file(project.path('.skippy/libs/my-lib/modules/gl/control.rb'))
    refute_file(project.path('.skippy/libs/my-lib/modules/gl/container.rb'))
    refute_file(project.path('.skippy/libs/my-lib/modules/tool.rb'))
  end

  def test_that_it_can_find_library_module
    use_fixture('my_project')
    project = Skippy::Project.new(work_path)
    library_source = fixture('my_lib')
    project.libraries.install(library_source)

    result = project.libraries.find_module('my-lib/command')
    assert_kind_of(Skippy::LibModule, result)
    assert_equal('my-lib/command', result.name)
  end

end
