# frozen_string_literal: true

require 'test_helper'
require 'skippy/library'

class SkippyLibraryTest < Skippy::Test

  def test_that_it_can_load_library_info
    lib_path = fixture('my_lib')
    library = Skippy::Library.new(lib_path)
    assert_equal(lib_path, library.path)
    assert_equal('my-lib', library.name)
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
      %w(my-lib/command my-lib/geometry my-lib/tool),
      library.modules.map(&:to_s)
    )
  end

  def test_that_it_return_its_name
    lib_path = fixture('my_lib')
    library = Skippy::Library.new(lib_path)
    assert_equal('my-lib', library.name)
  end

  def test_that_it_convert_to_string_as_name
    lib_path = fixture('my_lib')
    library = Skippy::Library.new(lib_path)
    assert_equal('my-lib', library.to_s)
  end

end
