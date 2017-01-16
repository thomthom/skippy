require 'test_helper'
require 'skippy/config'

class SkippyConfigTest < Skippy::Test

  def json_path
    fixture('my_lib').join('skippy.json')
  end

  def config_example
    config = Skippy::Config.new
    config.set('hello/nested/world', 1.618)
    config.set('hello/nested/universe', 3.14)
    config.set('hello/there', 'sexy')
    config
  end

  def test_that_it_can_load_json
    config = Skippy::Config.load(json_path)
    assert_equal(json_path, config.path)
    assert_equal("My Shiny Library", config[:name])
    assert_equal("1.2.3", config[:version])
  end

  def test_that_it_can_load_json_with_defaults
    defaults = {
      name: 'Untitled',
      version: '1.0.0',
      license: 'Apache'
    }
    config = Skippy::Config.load(json_path, defaults)
    assert_equal(json_path, config.path)
    assert_equal("My Shiny Library", config[:name])
    assert_equal("1.2.3", config[:version])
    assert_equal("Apache", config[:license])
  end

  def test_that_it_can_load_json_with_nested_defaults
    Dir.mktmpdir do |dir|
      config_json = Pathname.new(dir).join('config.json')
      config = config_example
      config.export(config_json)

      defaults = {
        hello: {
          nested: {
            world: 'default_value',
            space: 'time'
          }
        },
        foo: 123
      }
      config = Skippy::Config.load(config_json, defaults)
      assert_equal(1.618, config.get('hello/nested/world'))
      assert_equal('time', config.get('hello/nested/space'))
      assert_equal(123, config.get('foo'))
    end
  end

  def test_it_converts_to_string_like_a_hash
    config = Skippy::Config.load(json_path)
    assert_equal(config.to_hash.to_s, config.to_s)
  end

  def test_it_inspects_with_class_indicator
    config = Skippy::Config.load(json_path)
    assert_end_with(':Skippy::Config', config.inspect)
  end

  def test_it_can_set_nested_keys
    config = Skippy::Config.new
    config.set('hello/nested/world', 1.618)
    config.set('hello/nested/universe', 3.14)
    config.set('hello/there', 'sexy')
    assert_equal(1.618, config[:hello][:nested][:world])
    assert_equal(3.14, config[:hello][:nested][:universe])
    assert_equal('sexy', config[:hello][:there])
  end

  def test_it_can_set_with_symbol
    config = Skippy::Config.new
    config.set(:hello, 1.618)
    assert_equal(1.618, config[:hello])
  end

  def test_it_can_get_nested_keys
    config = Skippy::Config.new
    config.set('hello/nested/world', 1.618)
    config.set('hello/nested/universe', 3.14)
    config.set('hello/there', 'sexy')
    assert_equal(1.618, config.get('hello/nested/world'))
    assert_equal(3.14, config.get('hello/nested/universe'))
    assert_equal('sexy', config.get('hello/there'))
  end

  def test_it_can_get_keys_with_default_values
    config = Skippy::Config.new
    assert_nil(config.get('hello/nested/universe'))
    assert_equal(1.618, config.get('hello/nested/world', 1.618))
    assert_equal(3.14, config.get('hello', 3.14))
  end

  def test_it_can_get_with_symbol
    config = Skippy::Config.new
    config.set(:hello, 1.618)
    assert_equal(1.618, config.get(:hello))
  end

  def test_it_can_save_config
    Dir.mktmpdir do |dir|
      config_json = Pathname.new(dir).join('config.json')
      config = config_example
      refute(config_json.exist?)
      config.save_as(config_json)
      assert(config_json.exist?)
    end
  end

  def test_it_raises_error_if_saving_config_not_loaded_from_path
    Dir.mktmpdir do |dir|
      config_json = Pathname.new(dir).join('config.json')
      config = config_example
      assert_raises(Skippy::Config::MissingPathError) do
        config.save
      end
    end
  end

  def test_it_can_load_saved_config
    Dir.mktmpdir do |dir|
      config_json = Pathname.new(dir).join('config.json')
      config = config_example
      refute(config_json.exist?)
      config.export(config_json)
      assert(config_json.exist?)
      new_config = Skippy::Config.load(config_json)
      assert_equal(config, new_config)
    end
  end

  def test_it_can_bulk_update_with_normal_hash
    config = config_example
    config.update({
      hello: {
        nested: {
          world: 'new value',
          foo: 123
        }
      },
      biz: 'Baz'
    })
    assert_equal('new value', config.get('hello/nested/world'))
    assert_equal(123, config.get('hello/nested/foo'))
    assert_equal(3.14, config.get('hello/nested/universe'))
    assert_equal('sexy', config.get('hello/there'))
    assert_equal('Baz', config.get('biz'))
  end

  def test_it_can_bulk_update_with_key_paths
    config = config_example
    config.update({
      'hello/nested/world' => 'new value',
      'hello/nested/foo' => 123,
      'biz' => 'Baz',
    })
    assert_equal('new value', config.get('hello/nested/world'))
    assert_equal(123, config.get('hello/nested/foo'))
    assert_equal(3.14, config.get('hello/nested/universe'))
    assert_equal('sexy', config.get('hello/there'))
    assert_equal('Baz', config.get('biz'))
  end

end
