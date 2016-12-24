require 'skippy/namespace'

class Debug < Skippy::Command

  include Thor::Actions

  desc 'clean', 'Cleans out project files'
  def clean
    say "Cleaning out project files..."
    remove_file Skippy::Project::PROJECT_FILENAME
    remove_dir 'src'
  end

end
