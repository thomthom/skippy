require 'json'
require 'pathname'

module Skippy::ConfigAccessors

  private

  def config_attr(symbol, key = nil, type: nil)
    config_attr_read(symbol, key)
    config_attr_write(symbol, key, type: type)
    nil
  end

  def config_attr_read(symbol, key = nil)
    self.class_eval {
      define_method(symbol) {
        @config.get(key || symbol)
      }
    }
    nil
  end

  def config_attr_write(symbol, key = nil, type: nil)
    self.class_eval {
      symbol_set = "#{symbol}=".intern
      define_method(symbol_set) { |value|
        value = type.new(value) if type && !value.is_a?(type)
        @config.set(key || symbol, value)
        value
      }
    }
    nil
  end

end
