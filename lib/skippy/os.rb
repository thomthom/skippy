# frozen_string_literal: true

module Skippy

  if RUBY_PLATFORM =~ /darwin/
    require 'skippy/os/mac'
    OS = Skippy::OSMac
  else
    require 'skippy/os/win'
    OS = Skippy::OSWin
  end

  @os = OS.new

  def self.os
    @os
  end

end
