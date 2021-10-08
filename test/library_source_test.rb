# frozen_string_literal: true
require 'test_helper'
require 'skippy/lib_source'
require 'skippy/project'

class SkippyLibrarySourceTest < Skippy::Test

  attr_reader :domains, :project

  def setup
    domains = %w(
      bitbucket.org
      github.com
    )
    stub_request(:any, %r{https://bitbucket\.org.*/}).to_return(status: 404)
    stub_request(:any, 'https://github.com/thomthom/tt-lib.git')
    Dir.chdir(fixture('my_project'))
    @project = Skippy::Project.current
    @project.config.set(:sources, domains)
  end

  def test_it_understand_relative_local_filenames
    filename = '../my_lib'
    source = Skippy::LibrarySource.new(project, filename)
    refute(source.git?, 'Git')
    assert(source.local?, 'Local')
    assert(source.relative?, 'Relative')
    refute(source.absolute?, 'Absolute')
    assert_equal(filename, source.origin)
    assert_match(/^my_lib_local_/, source.lib_path)
  end

  def test_it_understand_absolute_local_filenames
    filename = File.expand_path('../my_lib')
    source = Skippy::LibrarySource.new(project, filename)
    refute(source.git?, 'Git')
    assert(source.local?, 'Local')
    refute(source.relative?, 'Relative')
    assert(source.absolute?, 'Absolute')
    assert_equal(filename, source.origin)
    assert_match(/^my_lib_local_/, source.lib_path)
  end

  def test_it_hashes_absolute_paths_for_local_sources
    path_relative = '../my_lib'
    source_relative = Skippy::LibrarySource.new(project, path_relative)
    path_absolute = File.expand_path('../my_lib')
    source_absolute = Skippy::LibrarySource.new(project, path_absolute)
    assert_equal(source_absolute.lib_path, source_relative.lib_path)
  end

  def test_it_understand_git_urls
    git_url = 'https://bitbucket.org/thomthom/tt-library-2.git'
    source = Skippy::LibrarySource.new(project, git_url)
    assert(source.git?, 'Git')
    refute(source.local?, 'Local')
    refute(source.relative?, 'Relative')
    assert(source.absolute?, 'Absolute')
    expected = 'https://bitbucket.org/thomthom/tt-library-2.git'
    assert_equal(expected, source.origin)
    assert_equal('tt-library-2_thomthom_bitbucket-org', source.lib_path)
    assert_nil(source.requirement)
    assert_nil(source.branch)
  end

  def test_it_understand_local_relative_git_paths
    git_url = '../git-lib'
    source = Skippy::LibrarySource.new(project, git_url)
    assert(source.git?, 'Git')
    assert(source.local?, 'Local')
    assert(source.relative?, 'Relative')
    refute(source.absolute?, 'Absolute')
    assert_equal(git_url, source.origin)
    assert(source.lib_path.start_with?('git-lib_local_'), source.lib_path)
    assert_nil(source.requirement)
    assert_nil(source.branch)
  end

  def test_it_understand_local_absolute_git_paths
    git_url = File.expand_path('../git-lib')
    source = Skippy::LibrarySource.new(project, git_url)
    assert(source.git?, 'Git')
    assert(source.local?, 'Local')
    refute(source.relative?, 'Relative')
    assert(source.absolute?, 'Absolute')
    assert_equal(0, source.origin.casecmp(git_url))
    assert(source.lib_path.start_with?('git-lib_local_'), source.lib_path)
    assert_nil(source.requirement)
    assert_nil(source.branch)
  end

  def test_it_understand_local_git_paths_with_backslashes
    git_url = File.expand_path('../git-lib')
    windows_path = git_url.tr('/', '\\')
    source = Skippy::LibrarySource.new(project, windows_path)
    assert(source.git?, 'Git')
    assert(source.local?, 'Local')
    refute(source.relative?, 'Relative')
    assert(source.absolute?, 'Absolute')
    assert_equal(0, source.origin.casecmp(git_url))
    assert(source.lib_path.start_with?('git-lib_local_'), source.lib_path)
    assert_nil(source.requirement)
    assert_nil(source.branch)
  end

  def test_it_understand_git_urls_with_usernames
    git_url = 'https://thomthom@bitbucket.org/thomthom/tt-library-2.git'
    source = Skippy::LibrarySource.new(project, git_url)
    assert(source.git?, 'Git')
    refute(source.local?, 'Local')
    refute(source.relative?, 'Relative')
    assert(source.absolute?, 'Absolute')
    expected = 'https://bitbucket.org/thomthom/tt-library-2.git'
    assert_equal(expected, source.origin)
    assert_equal('tt-library-2_thomthom_bitbucket-org', source.lib_path)
  end

  def test_it_understand_relative_library_source
    source_name = 'thomthom/tt-lib'
    source = Skippy::LibrarySource.new(project, source_name)
    assert(source.git?, 'Git')
    refute(source.local?, 'Local')
    refute(source.relative?, 'Relative')
    assert(source.absolute?, 'Absolute')
    expected = 'https://github.com/thomthom/tt-lib.git'
    assert_equal(expected, source.origin)
    assert_equal('tt-lib_thomthom_github-com', source.lib_path)
  end

  def test_it_normalize_library_requirement
    source_name = 'thomthom/tt-lib'
    options = {
      requirement: ' ~>  1.2.3',
    }
    source = Skippy::LibrarySource.new(project, source_name, options)
    assert_kind_of(String, source.requirement)
    assert_equal(source.requirement, '~> 1.2.3')
  end

  def test_it_does_not_prefix_exact_requirement
    source_name = 'thomthom/tt-lib'
    options = {
      requirement: '1.2.3',
    }
    source = Skippy::LibrarySource.new(project, source_name, options)
    assert_kind_of(String, source.requirement)
    assert_equal(source.requirement, '1.2.3')
  end

  def test_it_keeps_track_of_source_branch
    source_name = 'thomthom/tt-lib'
    options = {
      branch: 'dev-feature',
    }
    source = Skippy::LibrarySource.new(project, source_name, options)
    assert_kind_of(String, source.branch)
    assert_equal(source.branch, options[:branch])
  end

end
