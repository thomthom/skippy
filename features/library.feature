Feature: Libraries

  Developers should be able to use third-party libraries in their extensions.

  Background:
    I run `skippy new MyCorp::MyExtension`

  Scenario: Install a new library from local disk
    Given an empty file named ".temp/my_lib/skippy.json"
    And an empty directory ".temp/my_lib/src"
    When I run `skippy lib:install ~/temp/my_lib`
    Then a file named ".skippy/libs/my_lib/skippy.json" should exist
    And a directory named ".skippy/libs/my_lib/src" should exist

  Scenario: List installed libraries
    Given an empty file named ".skippy/libs/my_lib/src/command"
    And an empty file named ".skippy/libs/my_lib/src/geom"
    And an empty file named ".skippy/libs/my_lib/src/tool"
    When I run `skippy lib:list`
    Then the output should contain "my_lib/command"
    And the output should contain "my_lib/geom"
    And the output should contain "my_lib/tool"

  Scenario: Use a library component
    Given a file named ".skippy/libs/my_lib/src/command.rb" with:
      """
      module SkippyLib
        class Command
        end
      end # module
      """
    When I run `skippy lib:use my_lib/geom`
    Then a file named "src/my_extension/vendor/my_lib/command.rb" should contain:
      """
      module MyCorp::MyExtension
        class Command
        end
      end # module
      """
