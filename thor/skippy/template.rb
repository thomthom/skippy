require 'pathname'

require 'skippy/project'

class Skippy::Template

  attr_reader :name, :path
  attr_accessor :description

  def initialize(relative_template_path)
    @path = relative_template_path
    @name = ''
    @description = ''
  end

  def compile(project)
    options = { :namespace => project.namespace.to_s }
    basename = project.namespace.to_underscore
    relative_paths.each { |source|
      target = source.to_s
      target.gsub!(/\A#{Regexp.quote(path)}\/extension/, "src/#{basename}")
      target.gsub!(/.erb\z/, '.rb')
      yield(source.to_s, target, options)
    }
    nil
  end

  private

  def relative_paths
    pattern = File.join(self.class.source_root, path, '**', '*.erb')
    source_base = Pathname.new(self.class.source_root)
    Dir.glob(pattern).map { |file|
      pathname = Pathname.new(file)
      pathname.relative_path_from(source_base)
    }
  end

  # TODO(thomthom): Reuse path with Skippy::New.
  def self.source_root
    path = File.join(__dir__, '..', '..', 'thor', 'templates')
    File.expand_path(path)
  end

end
