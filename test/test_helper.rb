# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'skippy'

require 'minitest/autorun'
require 'minitest/reporters'
require 'pathname'
# require 'pry' # TODO: What was this used for?
require 'webmock/minitest'

# Kludge: minitest-reporter depend on the `ansi` gem which hasn't been updated
# for a very long time. It's expecting to use another `win32console` gem in
# order to provide colorized output on Windows even though that is not longer
# needed. This works around that by fooling Ruby to think it has been loaded.
#
# https://github.com/rubyworks/ansi/issues/36
# https://github.com/rubyworks/ansi/pull/35
$LOADED_FEATURES << 'Win32/Console/ANSI'
Minitest::Reporters.use!

class Skippy::Test < Minitest::Test

  def assert_same_elements(exp, act, msg = nil)
    msg = message(msg, E) { diff exp, act }
    assert_equal(exp, exp & act, msg)
  end

  def assert_all_kind_of(klass, elements, msg = nil)
    elements.each { |element|
      assert_kind_of(klass, element, msg)
    }
  end

  def assert_end_with(exp, act, msg = nil)
    msg = message(msg, E) { diff exp, act }
    assert(act.end_with?(exp), msg)
  end

  def assert_file(path, msg = nil)
    pathname = Pathname.new(path)
    msg ||= "expected a file named: #{path}"
    assert_predicate(pathname, :file?, msg)
  end

  def refute_file(path, msg = nil)
    pathname = Pathname.new(path)
    msg ||= "did not expect a file named: #{path}"
    refute_predicate(pathname, :file?, msg)
  end

  def assert_directory(path, msg = nil)
    pathname = Pathname.new(path)
    msg ||= "expected a directory named: #{path}"
    assert_predicate(pathname, :directory?, msg)
  end

  def refute_directory(path, msg = nil)
    pathname = Pathname.new(path)
    msg ||= "did not expect a directory named: #{path}"
    refute_predicate(pathname, :directory?, msg)
  end

  private

  # Returns the path to a named fixture in the project.
  # @return [Pathname]
  def fixture(fixture_name)
    skippy_root.join('fixtures', fixture_name)
  end

  # The root of the skippy project.
  # @return [Pathname]
  def skippy_root
    Pathname.new(__dir__).parent
  end

end


class Skippy::Test::Fixture < Skippy::Test

  attr_reader :work_path

  def setup
    super
    @work_path = Dir.mktmpdir
    @original_pwd = Dir.pwd
    Dir.chdir(work_path)
  end

  def teardown
    super
    Dir.chdir(@original_pwd)
    FileUtils.remove_entry(work_path)
  end

  private

  def use_fixture(fixture_name)
    source = fixture(fixture_name)
    raise "Fixture #{fixture_name} not found" unless source.exist?

    FileUtils.copy_entry(source, work_path, false, false, true)
  end

end


module SkippyTestHelper

  def boot_loader_path
    File.expand_path('../app/boot.rb', __dir__)
  end

  def ignored_commands
    [
      Thor, Thor::Group,
      Skippy::Command, Skippy::Command::Group,
    ]
  end

  def loaded_commands
    Thor::Base.subclasses - ignored_commands
  end

end
