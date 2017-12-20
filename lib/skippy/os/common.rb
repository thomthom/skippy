class Skippy::OSCommon

  # @param [String] command
  def execute_command(command)
    # Something with a Thor application like skippy get the 'RUBYLIB'
    # environment set which prevents SketchUp from finding its StdLib
    # directories. (At least under Windows.) This relates to child processes
    # inheriting the environment variables of its parent.
    # To work around this we unset RUBYLIB before launching SketchUp. This
    # doesn't affect skippy as it's about to exit as soon as SketchUp starts
    # any way.
    ENV['RUBYLIB'] = nil if ENV['RUBYLIB']
    id = spawn(command)
    Process.detach(id)
  end

  # @param [String] path
  def launch_app(path, *args)
    raise NotImplementedError
  end

  def sketchup_apps
    raise NotImplementedError
  end

end
