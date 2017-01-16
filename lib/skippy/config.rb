require 'json'
require 'pathname'

class Skippy::Config < Hash

  attr_accessor :path

  class MissingPathError < RuntimeError; end

  def self.load(path, defaults = {})
    if path.exist?
      json = File.read(path)
      config = JSON.parse(json,
        symbolize_names: true,
        object_class: self
      )
    else
      config = self.new
    end
    # Need to merge nested defaults.
    config.merge!(defaults) { |key, value, default|
      if value.is_a?(Hash) && default.is_a?(Hash)
        # Deep merge in order to merge nested hashes.
        # Note: This currently doesn't merge arrays.
        # http://stackoverflow.com/a/9381776/486990
        merger = proc { |key, v1, v2|
          Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2
        }
        default.merge(value, &merger)
      else
        value || default
      end
    }
    config.path = path
    config
  end

  def get(key_path, default = nil)
    get_item(key_path) || default
  end

  def set(key_path, value)
    set_item(key_path, value)
  end

  def export(target_path)
    json = JSON.pretty_generate(self)
    File.write(target_path, json)
    nil
  end

  def save_as(target_path)
    export(target_path)
    @path = target_path
    nil
  end

  def save
    raise MissingPathError if path.nil?
    export(path)
  end

  def path=(new_path)
    @path = Pathname.new(new_path)
  end

  def update(hash)
    if hash.keys.first.is_a?(String)
      update_from_key_paths(hash)
    else
      update_from_hash(hash)
    end
    self
  end

  def inspect
    "#{super}:#{self.class.name}"
  end

  private

  def update_from_hash(hash)
    merger = proc { |key, v1, v2|
      Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2
    }
    merge!(hash, &merger)
  end

  def update_from_key_paths(key_paths)
    key_paths.each { |key_path, value|
      set(key_path, value)
    }
  end

  def key_parts(key_path)
    if key_path.is_a?(Symbol)
      [key_path]
    else
      key_path.split('/').map { |key| key.intern }
    end
  end

  def get_item(key_path)
    parts = key_parts(key_path)
    return nil if parts.empty?
    item = self
    parts.each { |key|
      return nil if item.nil?
      item = item[key]
    }
    item
  end

  def set_item(key_path, value)
    item = self
    parts = key_parts(key_path)
    last_key = parts.pop
    parts.each { |key|
      item[key] ||= self.class.new
      item = item[key]
    }
    item[last_key] = value
    nil
  end

end
