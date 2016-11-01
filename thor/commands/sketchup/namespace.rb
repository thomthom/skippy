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

  def to_a
    @namespace.split('::')
  end

  def to_s
    @namespace.dup
  end

  private

  def valid?(namespace)
    to_a.all? { |part| /^[[:upper:]]/.match(part) }
  end

end