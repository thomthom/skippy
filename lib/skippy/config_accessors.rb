require 'json'
require 'pathname'

module Skippy::ConfigAccessors

  private

  def config_attr(*symbols, key: nil, default: nil, type: nil)
    config_attr_reader(*symbols, key: key, type: type, default: default)
    config_attr_writer(*symbols, key: key, type: type)
    nil
  end

  def config_attr_reader(*symbols, key: nil, default: nil, type: nil)
    class_eval do
      symbols.each { |symbol|
        raise TypeError unless symbol.is_a?(Symbol)

        define_method(symbol) do
          value = @config.get(key || symbol, default)
          value = type.new(value) if type && !value.is_a?(type)
          value
        end
      }
    end
    nil
  end

  def config_attr_writer(*symbols, key: nil, type: nil)
    class_eval do
      symbols.each { |symbol|
        raise TypeError unless symbol.is_a?(Symbol)

        symbol_set = "#{symbol}=".intern
        define_method(symbol_set) do |value|
          value = type.new(value) if type && !value.is_a?(type)
          @config.set(key || symbol, value)
          value
        end
      }
    end
    nil
  end

end
