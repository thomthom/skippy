class Skippy::Namespace

  def initialize(namespace)
    unless valid?(namespace)
      raise Skippy::Error, "'#{namespace}' is not a valid Ruby namespace"
    end
    @namespace = namespace
  end

  def to_s
    @namespace.dup
  end

  private

  def valid?(namespace)
    parts = namespace.split('::')
    parts.all? { |part| /^[[:upper:]]/.match(part) }
  end

end