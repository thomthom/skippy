Feature: Libraries

  Developers should be able to use third-party libraries in their extensions.

  Background:
    Given I run `skippy new Example::HelloWorld`

  Scenario: Install a new library from local disk
    Given a file named "./temp/my_lib/skippy.json" with:
      """
      {
        "library": true,
        "name": "My Shiny Library",
        "version": "1.2.3"
      }
      """
    And an empty directory "./temp/my_lib/src"
    When I run `skippy lib:install ./temp/my_lib`
    Then a file named ".skippy/libs/my_lib/skippy.json" should exist
    And a directory named ".skippy/libs/my_lib/src" should exist
    And a file named "skippy.json" should contain json fragment:
      """
      {
        "libraries": [
          {
            "name": "my_lib",
            "version": "1.2.3",
            "source": "./temp/my_lib"
          }
        ]
      }
      """
    And the output should contain "Installed library: my_lib (1.2.3)"

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
    When I run `skippy lib:use my_lib/command`
    Then a file named "src/hello_world/vendor/my_lib/command.rb" should contain:
      """
      module Example::HelloWorld
        class Command
        end
      end # module
      """
    And a file named "skippy.json" should contain json fragment:
      """
      {
        "modules": [
          "my_lib/command"
        ]
      }
      """
