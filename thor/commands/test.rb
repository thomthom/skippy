require 'skippy/command'

require_relative 'sketchup/project'

class Skippy::CLI < Skippy::Command
  class Newgem < Thor::Group

    #namespace :newgem

    include Thor::Actions

    argument :namespace
    class_option :test_framework, :default => :test_unit

    def self.source_root
      path = File.join(__dir__, '..', '..', 'thor', 'templates')
      File.expand_path(path)
    end

    def create_project_json
      say 'Creating project json...'
    end

  end
end


class Foo < Skippy::Command
  desc 'bar NAMESPACE', 'Something Foo'
  def bar(namespace)
    say "Hello #{namespace}"
  end
end


class Bar < Thor::Group

  #namespace :newgem

  include Thor::Actions

  argument :namespace
  class_option :test_framework, :default => :test_unit

  def self.source_root
    path = File.join(__dir__, '..', '..', 'thor', 'templates')
    File.expand_path(path)
  end

  def create_project_json
    say 'Creating project json...'
  end

  def create_magic
    say 'Creating magic...'
  end

end


class Jungle < Thor
  desc 'monkey', 'Oook'
  def monkey(namespace)
    say 'Oooook'
  end
end
