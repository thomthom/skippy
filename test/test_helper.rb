$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'skippy'

require 'minitest/autorun'


module SkippyTestHelper

  def boot_loader_path
    File.expand_path('../app/boot.rb', __dir__)
  end

  def ignored_commands
    [
      Thor, Thor::Group,
      Skippy::Command, Skippy::Command::Group
    ]
  end

  def loaded_commands
    Thor::Base.subclasses - ignored_commands
  end

end
