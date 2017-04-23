require 'test_helper'
require 'skippy/namespace'

class SkippyNamespaceTest < Minitest::Test

  # Helper assert that will output the string that caused the test to fail.
  def assert_invalid(namespace)
    assert_raises(Skippy::Error, namespace) do
      Skippy::Namespace.new(namespace)
    end
  end


  def test_that_it_accept_a_namespace_with_no_nesting
    namespace = Skippy::Namespace.new('Example')
    assert_equal('Example', namespace.basename)
    assert_equal(%w(Example), namespace.to_a)
    assert_equal('Example', namespace.to_name)
    assert_equal('example', namespace.to_underscore)
    assert_equal('module Example', namespace.open)
    assert_equal('end # module Example', namespace.close)
  end

  def test_that_it_accept_nested_namespaces
    namespace = Skippy::Namespace.new('Example::HelloWorld')
    assert_equal('HelloWorld', namespace.basename)
    assert_equal(%w(Example HelloWorld), namespace.to_a)
    assert_equal('Hello World', namespace.to_name)
    assert_equal('hello_world', namespace.to_underscore)
    assert_equal(
      "module Example\nmodule HelloWorld",
      namespace.open
    )
    assert_equal(
      "end # module HelloWorld\nend # module Example",
      namespace.close
    )
  end

  def test_that_it_produce_compact_short_names
    namespace = Skippy::Namespace.new('TT::Plugins::SUbD')
    assert_equal('TT_SUbD', namespace.short_name)

    namespace = Skippy::Namespace.new('TT::Plugins::VertexTools')
    assert_equal('TT_VertexTools', namespace.short_name)

    namespace = Skippy::Namespace.new('TT::Plugins::VertexTools')
    assert_equal('TT_VertexTools', namespace.short_name)

    namespace = Skippy::Namespace.new('TT::Plugins::HelloWorld')
    assert_equal('TT_HelloWorld', namespace.short_name)

    namespace = Skippy::Namespace.new('Example::HelloWorld')
    assert_equal('Ex_HelloWorld', namespace.short_name)

    namespace = Skippy::Namespace.new('FooBar::HelloWorld')
    assert_equal('FB_HelloWorld', namespace.short_name)

    namespace = Skippy::Namespace.new('FooBarLoremIpsum::HelloWorld')
    assert_equal('FBLI_HelloWorld', namespace.short_name)

    namespace = Skippy::Namespace.new('HelloWorld')
    assert_equal('HelloWorld', namespace.short_name)
  end

  def test_that_it_reject_invalid_namespaces
    assert_invalid('123_number_first')
    assert_invalid('lower_case_first')
    assert_invalid('$_symbol_first')
  end

end
