require 'test_helper'
require 'skippy/library'

class SkippyLibraryTest < Skippy::Test

  def test_that_it_can_load_library_info
    lib_path = fixture('my_lib')
    library = Skippy::Library.new(lib_path)
    assert_equal(lib_path, library.path)
    assert_equal('My Shiny Library', library.title)
    assert_equal('my_lib', library.name)
    assert_equal('1.2.3', library.version)
  end

  def test_that_it_fails_when_library_path_does_not_exist
    assert_raises(Skippy::Library::LibraryNotFoundError) do
      Skippy::Library.new('./bogus/path')
    end
  end

  def test_that_it_can_find_library_modules
    lib_path = fixture('my_lib')
    library = Skippy::Library.new(lib_path)
    assert_all_kind_of(Skippy::LibModule, library.modules)
    assert_same_elements(
      %w(my_lib/command my_lib/geometry my_lib/tool),
      library.modules.map { |mod| mod.to_s }
    )
  end

end
