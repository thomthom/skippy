# frozen_string_literal: true
require 'skippy/namespace'

class Debug < Skippy::Command

  include Thor::Actions

  desc 'clean', 'Cleans out project files'
  def clean
    say 'Cleaning out project files...'
    remove_file Skippy::Project::PROJECT_FILENAME
    remove_dir 'src'
    remove_dir 'skippy'
    remove_dir '.skippy'
  end

end
