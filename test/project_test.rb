require 'test_helper'
require 'skippy/project'
require 'json'
require 'pathname'

class SkippyProjectTest < Minitest::Test

  def test_that_it_can_create_transient_project
    test_path = Pathname.new(__dir__)
    project = Skippy::Project.new(test_path)
    assert_equal(test_path, project.path)
    refute(project.exist?)
    refute(File.exist?(project.filename))
  end

  def test_that_it_initializes_default_values
    test_path = Pathname.new(__dir__)
    project = Skippy::Project.new(test_path)
    refute_empty(project.name)
    assert_empty(project.description)
    refute_empty(project.author)
    refute_empty(project.copyright)
    refute_empty(project.license)
    refute_empty(project.namespace.to_s)
  end

  def test_that_it_creates_project_json
    Dir.mktmpdir do |dir|
      test_path = Pathname.new(dir)
      project = Skippy::Project.new(test_path)
      assert_equal(test_path, project.path)
      refute(project.exist?)
      refute(File.exist?(project.filename))
      project.save
      assert(project.exist?)
      assert(File.exist?(project.filename))
    end
  end

  def test_that_it_loads_project_json
    Dir.mktmpdir do |dir|
      test_path = Pathname.new(dir)
      existing_project = Skippy::Project.new(test_path)
      existing_project.namespace = 'HelloWorld'
      existing_project.save
      project = Skippy::Project.new(test_path)
      assert_equal(existing_project.namespace.to_s, project.namespace.to_s)
      assert_equal(existing_project.name, project.name)
      assert_equal(existing_project.description, project.description)
      assert_equal(existing_project.author, project.author)
      assert_equal(existing_project.copyright, project.copyright)
      assert_equal(existing_project.license, project.license)
    end
  end

  def test_project_json_content
    test_path = Pathname.new(__dir__)
    project = Skippy::Project.new(test_path)
    json = JSON.parse(project.to_json, symbolize_names: true)
    assert(json.key?(:namespace))
    assert(json.key?(:name))
    assert(json.key?(:description))
  end

end
