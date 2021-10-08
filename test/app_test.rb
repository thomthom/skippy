# frozen_string_literal: true

require 'test_helper'
require 'skippy/app'
require 'pathname'

class SkippyAppTest < Minitest::Test

  include SkippyTestHelper

  def test_that_it_boots_the_app_commands
    # Cannot assert there are not loaded commands because the other
    # tests might have booted the app.
    # assert_equal(0, loaded_commands.size, loaded_commands)
    Skippy::App.boot(boot_loader_path)
    refute_equal(0, loaded_commands.size, loaded_commands)
  end

  def test_that_it_finds_the_app_templates
    app = Skippy::App.boot(boot_loader_path)
    refute_equal(0, app.templates.size)
    app.templates.each { |template|
      assert_kind_of(Pathname, template)
      assert(template.directory?, "Template not found: #{template}")
    }
  end

  def test_that_it_returns_a_valid_templates_path
    app = Skippy::App.boot(boot_loader_path)
    path = app.templates_source_path
    assert_kind_of(Pathname, path)
    assert(path.directory?, path)
  end

  def test_that_it_returns_a_valid_resources_path
    app = Skippy::App.boot(boot_loader_path)
    path = app.resources
    assert_kind_of(Pathname, path)
    assert(path.directory?, path)
  end

  def test_that_it_returns_a_valid_resources_sub_path
    app = Skippy::App.boot(boot_loader_path)
    path = app.resources('commands')
    assert_kind_of(Pathname, path)
    assert(path.directory?, path)
  end

end
