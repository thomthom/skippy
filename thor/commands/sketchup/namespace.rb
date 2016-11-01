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
    parts(@namespace)
  end

  def to_s
    @namespace.dup
  end

  private

  def parts(namespace)
    namespace.split('::')
  end

  def valid?(namespace)
    parts(namespace).all? { |part| /^[[:upper:]]/.match(part) }
  end

end