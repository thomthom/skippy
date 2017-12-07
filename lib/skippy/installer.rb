require 'skippy/error'
require 'skippy/lib_source'
require 'skippy/library'
require 'skippy/project'

module Skippy

  class BranchNotFound < Skippy::Error; end
  class TagNotFound < Skippy::Error; end
  class UnknownSourceType < Skippy::Error; end

end

class Skippy::LibraryInstaller

  attr_reader :project, :source

  # @param [Skippy::Project] project
  # @param [Skippy::LibrarySource] source
  def initialize(project, lib_source)
    @project = project
    @source = lib_source
    @messager = nil
  end

  def on_status(&block)
    @messager = block
  end

  # @return [Skippy::Library]
  def install
    raise NotImplementedError
  end

  private

  # @param [Symbol] type
  # @param [String] message
  def status(type, message)
    @messager.call(type, message) if @messager
  end

  # @param [String] message
  def info(message)
    status(:info, message)
  end

  # @param [String] message
  def warning(message)
    status(:warning, "Warning: #{message}")
  end

  # @return [Pathname]
  def path
    project.libraries.path
  end

end
