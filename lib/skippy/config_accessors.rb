require 'json'
require 'pathname'

module Skippy::ConfigAccessors

  private

  def config_attr(*symbols, key: nil, type: nil)
    config_attr_reader(*symbols, key: key, type: type)
    config_attr_writer(*symbols, key: key, type: type)
    nil
  end

  def config_attr_reader(*symbols, key: nil, type: nil)
    self.class_eval {
      symbols.each { |symbol|
        raise TypeError unless symbol.is_a?(Symbol)
        define_method(symbol) {
          value = @config.get(key || symbol)
          value = type.new(value) if type && !value.is_a?(type)
          value
        }
      }
    }
    nil
  end

  def config_attr_writer(*symbols, key: nil, type: nil)
    self.class_eval {
      symbols.each { |symbol|
        raise TypeError unless symbol.is_a?(Symbol)
        symbol_set = "#{symbol}=".intern
        define_method(symbol_set) { |value|
          value = type.new(value) if type && !value.is_a?(type)
          @config.set(key || symbol, value)
          value
        }
      }
    }
    nil
  end

end
