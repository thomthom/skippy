require 'skippy/error'

class Skippy::Namespace

  def initialize(namespace)
    unless valid?(namespace)
      raise Skippy::Error, "'#{namespace}' is not a valid Ruby namespace"
    end

    @namespace = namespace
  end

  def basename
    to_a.last
  end

  # Creates a compact string from the namespace. First part composed of the
  # capitals from the first part followed by the last item of the namespace.
  #
  # The prefix will always have at least two characters.
  #
  # If the namespace isn't nested it will just return the namespace string.
  #
  # @return [String]
  def short_name
    items = to_a
    return to_s unless items.size > 1

    initials = items.first.scan(/[[:upper:]]/)
    prefix = initials.size > 1 ? initials.join : items.first[0, 2]
    "#{prefix}_#{items.last}"
  end

  def open
    @open ||= to_a.map { |part| "module #{part}" }.join("\n")
  end

  def close
    @close ||= to_a.reverse.map { |part| "end # module #{part}" }.join("\n")
  end

  def to_a
    parts(@namespace)
  end

  def to_name
    basename_words(basename).join(' ')
  end

  def to_s
    @namespace.dup
  end

  def to_str
    to_s
  end

  def to_underscore
    basename_words(basename).map(&:downcase).join('_')
  end

  private

  def basename_words(namespace_basename)
    result = namespace_basename.scan(/[[:upper:]]+[[:lower:][:digit:]]*/)
    result.empty? ? [namespace_basename.dup] : result
  end

  def parts(namespace)
    namespace.split('::')
  end

  def valid?(namespace)
    parts(namespace).all? { |part| /^[[:upper:]]/.match(part) }
  end

end
