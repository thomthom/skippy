require 'test_helper'
require 'skippy/lib_source'

class SkippyLibrarySourceTest < Skippy::Test

  attr_reader :domains

  def setup
    @domains = %w(
      bitbucket.org
      github.com
    )
    stub_request(:any, %r{https://bitbucket\.org.*/}).to_return(status: 404)
    stub_request(:any, 'https://github.com/thomthom/tt-lib.git')
    Dir.chdir(fixture('my_project'))
  end

  def test_it_understand_relative_local_filenames
    filename = '../my_lib'
    source = Skippy::LibrarySource.new(filename)
    refute(source.git?, 'Git')
    assert(source.local?, 'Local')
    assert(source.relative?, 'Relative')
    refute(source.absolute?, 'Absolute')
    assert_equal(filename, source.origin)
  end

  def test_it_understand_absolute_local_filenames
    filename = File.expand_path('../my_lib')
    source = Skippy::LibrarySource.new(filename)
    refute(source.git?, 'Git')
    assert(source.local?, 'Local')
    refute(source.relative?, 'Relative')
    assert(source.absolute?, 'Absolute')
    assert_equal(filename, source.origin)
  end

  def test_it_understand_git_urls
    git_url = 'https://bitbucket.org/thomthom/tt-library-2.git'
    source = Skippy::LibrarySource.new(git_url, domains)
    assert(source.git?, 'Git')
    refute(source.local?, 'Local')
    refute(source.relative?, 'Relative')
    assert(source.absolute?, 'Absolute')
    expected = 'https://bitbucket.org/thomthom/tt-library-2.git'
    assert_equal(expected, source.origin)
  end

  def test_it_understand_git_urls_with_usernames
    git_url = 'https://thomthom@bitbucket.org/thomthom/tt-library-2.git'
    source = Skippy::LibrarySource.new(git_url, domains)
    assert(source.git?, 'Git')
    refute(source.local?, 'Local')
    refute(source.relative?, 'Relative')
    assert(source.absolute?, 'Absolute')
    expected = 'https://bitbucket.org/thomthom/tt-library-2.git'
    assert_equal(expected, source.origin)
  end

  def test_it_understand_relative_library_source
    source_name = 'thomthom/tt-lib'
    source = Skippy::LibrarySource.new(source_name, domains)
    assert(source.git?, 'Git')
    refute(source.local?, 'Local')
    refute(source.relative?, 'Relative')
    assert(source.absolute?, 'Absolute')
    expected = 'https://github.com/thomthom/tt-lib.git'
    assert_equal(expected, source.origin)
  end

end
