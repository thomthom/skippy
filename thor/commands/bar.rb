require 'skippy/command'

class Skippy::CLI < Skippy::Command
  desc "bar", "Prints bar"
  def bar
    puts "bar"
  end

  desc "cheese", "Prints cheese"
  def cheese
    puts "cheese"
  end
end
