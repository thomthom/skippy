$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'skippy'

require 'minitest/autorun'
require 'pathname'
require 'webmock/minitest'

class Skippy::Test < Minitest::Test

  def assert_same_elements(exp, act, msg = nil)
    msg = message(msg, E) { diff exp, act }
    assert(exp == exp & act, msg)
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
    assert(pathname.file?, msg)
  end

  def refute_file(path, msg = nil)
    pathname = Pathname.new(path)
    msg ||= "did not expect a file named: #{path}"
    refute(pathname.file?, msg)
  end

  def assert_directory(path, msg = nil)
    pathname = Pathname.new(path)
    msg ||= "expected a directory named: #{path}"
    assert(pathname.directory?, msg)
  end

  def refute_directory(path, msg = nil)
    pathname = Pathname.new(path)
    msg ||= "did not expect a directory named: #{path}"
    refute(pathname.directory?, msg)
  end

  private

  def fixture(fixture_name)
    skippy_root.join('fixtures', fixture_name)
  end

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
