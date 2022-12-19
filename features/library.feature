Feature: Libraries

  Developers should be able to use third-party libraries in their extensions.

  Scenario: List installed libraries
    Given I use a fixture named "project_with_lib"
    When I run `skippy lib:list`
    Then the output should contain "my-lib/command"
    And the output should contain "my-lib/gl"
    And the output should contain "my-other-lib/something"

  Scenario: List no installed libraries
    Given I use a fixture named "my_project"
    When I run `skippy lib:list`
    Then the output should contain "No libraries installed"

  Scenario: Use a library module
    Given I use a fixture named "project_with_lib"
    When I run `skippy lib:use my-lib/gl`
    Then the output should contain "Using module: my-lib/gl"
    And a file named "src/hello_world/vendor/my-lib/gl.rb" should exist
    And a file named "src/hello_world/vendor/my-lib/gl.rb" should contain:
      """
      module Example::HelloWorld
        module GL
        end
      end # module
      """
    And a file named "src/hello_world/vendor/my-lib/gl/control.rb" should exist
    And a file named "src/hello_world/vendor/my-lib/gl/container.rb" should exist
    And a file named "src/hello_world/vendor/my-lib/gl/container.rb" should contain:
      """
      Sketchup.require 'hello_world/vendor/my-lib/gl/control'

      module Example::HelloWorld
        module GL
          class Container < Control
          end
        end
      end # module
      """
    And a file named "skippy.json" should contain json fragment:
      """
      {
        "modules": [
          "my-lib/command",
          "my-lib/gl",
          "my-other-lib/something"
        ]
      }
      """

  Scenario: Remove a module
    Given I use a fixture named "project_with_lib"
    When I run `skippy lib:remove my-lib/command`
    And I run `skippy lib:list`
    Then the output should contain "Removed module: my-lib/command"
    And the file "src/hello_world/vendor/my-lib/command.rb" should not exist
    And a file named "skippy.json" should contain json fragment:
      """
      {
        "modules": [
          "my-other-lib/something"
        ]
      }
      """

  # Checks if used modules needs updating. (if the gem source changed)
  # skippy lib:check

  # Update used modules. (if gem sources changed then re-apply modules)
  # skippy lib:update

  # List project library dependencies (skippy libs)
  # skippy lib:list

  # List project modules used/available.
  # skippy lib:modules
  # skippy lib:modules:used
  # skippy lib:modules:available (unused?)
