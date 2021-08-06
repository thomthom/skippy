require 'test_helper'
require 'skippy/os/common'
# require 'pathname'

class SkippyOSCommonTest < Skippy::Test

  def test_that_it_can_parse_app_version_from_windows_paths
    os = Skippy::OSCommon.new
    test_data = {
      # Version 1 and 2 didn't have version numbers in their installation paths.
      # 'C:\Program Files (x86)\@Last Software\SketchUp' => 2,
      'C:\Program Files (x86)\@Last Software\SketchUp 3.0' => 3,
      'C:\Program Files (x86)\@Last Software\SketchUp 4' => 4,
      'C:\Program Files (x86)\@Last Software\SketchUp 5' => 5,
      'C:\Program Files (x86)\Google\Google SketchUp 6' => 6,
      'C:\Program Files (x86)\Google\Google SketchUp 7' => 7,
      'C:\Program Files (x86)\Google\Google SketchUp 8' => 8,
      'C:\Program Files (x86)\SketchUp\SketchUp 2013' => 2013,
      'C:\Program Files (x86)\SketchUp\SketchUp 2014' => 2014,
      'C:\Program Files\SketchUp\SketchUp 2015' => 2015,
      'C:\Program Files\SketchUp\SketchUp 2016' => 2016,
      'C:\Program Files\SketchUp\SketchUp 2017' => 2017,
      'C:\Program Files\SketchUp\SketchUp 2018' => 2018,
      'C:\Program Files\SketchUp\SketchUp 2019' => 2019,
      'C:\Program Files\SketchUp\SketchUp 2020' => 2020,
      'C:\Program Files\SketchUp\SketchUp 2021' => 2021,
      'C:\Program Files\SketchUp\SketchUp 2090 Alpha' => 2090,
      'C:\Program Files\SketchUp\SketchUp Viewer' => nil,
    }
    test_data.each { |path, expected|
      version = os.sketchup_version_from_path(path)
      if expected.nil? # Because minitest is very opinionated.
        assert_nil(version)
      else
        assert_equal(expected, version)
      end
    }
  end

  def test_that_it_can_parse_app_version_from_mac_paths
    os = Skippy::OSCommon.new
    test_data = {
      # Note: Not sure what the path names were for Google era SketchUp.
      '/Applications/Google SketchUp 6' => 6,
      '/Applications/Google SketchUp 7' => 7,
      '/Applications/Google SketchUp 8' => 8,
      '/Applications/SketchUp 2013' => 2013,
      '/Applications/SketchUp 2014' => 2014,
      '/Applications/SketchUp 2015' => 2015,
      '/Applications/SketchUp 2016' => 2016,
      '/Applications/SketchUp 2017' => 2017,
      '/Applications/SketchUp 2018' => 2018,
      '/Applications/SketchUp 2019' => 2019,
      '/Applications/SketchUp 2020' => 2020,
      '/Applications/SketchUp 2021' => 2021,
      '/Applications/SketchUp 2090 Alpha' => 2090,
      '/Applications/SketchUp Viewer' => nil,
    }
    test_data.each { |path, expected|
      version = os.sketchup_version_from_path(path)
      if expected.nil? # Because minitest is very opinionated.
        assert_nil(version)
      else
        assert_equal(expected, version)
      end
    }
  end

end
