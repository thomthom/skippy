# TODO(thomthom): Test file. Remove this.

require 'skippy/command'

class Skippy::CLI < Skippy::Command
  desc "foo", "Prints foo"
  def foo
    #puts "foo"
    say "foo", :green
  end
end
