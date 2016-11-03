require 'skippy/command'
require 'skippy/group'
require 'skippy/project'


class Hello < Skippy::Command
  desc 'world NAMESPACE', 'Oh, hi there!'
  def world(namespace)
    say "Hello #{namespace}"
  end
  default_command(:world)
end


class Bar < Skippy::Command::Group

  #namespace :newgem

  include Thor::Actions

  argument :foo
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


class Jungle < Skippy::Command
  desc 'monkey', 'Oook'
  def monkey(namespace)
    say 'Oooook'
  end
end
