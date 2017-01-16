require 'test_helper'
require 'pathname'
require 'skippy/config'
require 'skippy/config_accessors'

class SkippyConfigAccessorsTest < Skippy::Test

  class Dummy

    extend Skippy::ConfigAccessors

    config_attr(:foo)
    config_attr(:biz, type: Pathname)
    config_attr(:world, 'hello/nested/world')

    def initialize
      @config = config_example
    end

    def config_example
      config = Skippy::Config.new
      config.set('hello/nested/world', 1.618)
      config.set('hello/universe', 3.14)
      config.set('foo', 'bar')
      config.set('biz', Pathname.new('baz'))
      config
    end

  end # Dummy


  def test_that_it_can_access_a_config_property
    dummy = Dummy.new
    assert_equal('bar', dummy.foo)
    dummy.foo = 123
    assert_equal(123, dummy.foo)
  end

  def test_that_it_can_access_a_typed_config_property
    dummy = Dummy.new
    assert_kind_of(Pathname, dummy.biz)
    assert_equal('baz', dummy.biz.to_s)
    dummy.biz = 'implicit conversion'
    assert_kind_of(Pathname, dummy.biz)
    assert_equal('implicit conversion', dummy.biz.to_s)
  end

  def test_that_it_can_access_nested_config_properties
    dummy = Dummy.new
    assert_equal(1.618, dummy.world)
    dummy.world = 3.14
    assert_equal(3.14, dummy.world)
  end

end
