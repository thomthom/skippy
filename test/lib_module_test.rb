require 'test_helper'
require 'skippy/lib_module'

class SkippyLibModuleTest < Skippy::Test

  def test_that_it_can_load_module_info
    lib_path = fixture('my_lib')
    module_path = lib_path.join('src', 'command.rb')
    lib_module = Skippy::LibModule.new(module_path)
    assert_equal(module_path, lib_module.path)
    assert_equal('command', lib_module.basename)
    assert_equal('my_lib/command', lib_module.name)
  end

  def test_that_it_fails_when_module_path_does_not_exist
    assert_raises(Skippy::LibModule::ModuleNotFoundError) do
      Skippy::LibModule.new('./bogus/path')
    end
  end

end
