$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'skippy'

require 'minitest/autorun'
require 'pathname'

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

  private

  def fixture(fixture_name)
    skippy_root.join('fixtures', fixture_name)
  end

  def skippy_root
    Pathname.new(__dir__).parent
  end

end


module SkippyTestHelper

  def boot_loader_path
    File.expand_path('../app/boot.rb', __dir__)
  end

  def ignored_commands
    [
      Thor, Thor::Group,
      Skippy::Command, Skippy::Command::Group
    ]
  end

  def loaded_commands
    Thor::Base.subclasses - ignored_commands
  end

end
