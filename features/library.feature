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
    And an empty directory "./temp/my_lib/modules"
    When I run `skippy lib:install ./temp/my_lib`
    Then a file named ".skippy/libs/my_lib/skippy.json" should exist
    And a directory named ".skippy/libs/my_lib/modules" should exist
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
    Given a file named ".skippy/libs/my_lib/skippy.json" with:
      """
      {
        "library": true,
        "name": "My Shiny Library",
        "version": "1.2.3"
      }
      """
    And an empty file named ".skippy/libs/my_lib/modules/command.rb"
    And an empty file named ".skippy/libs/my_lib/modules/geom.rb"
    And an empty file named ".skippy/libs/my_lib/modules/gl.rb"
    And an empty file named ".skippy/libs/my_lib/modules/gl/cache.rb"
    And an empty file named ".skippy/libs/my_lib/modules/gl/container.rb"
    And an empty file named ".skippy/libs/my_lib/modules/gl/control.rb"
    And an empty file named ".skippy/libs/my_lib/modules/tool.rb"
    When I run `skippy lib:list`
    Then the output should contain "my_lib/command"
    And the output should contain "my_lib/geom"
    And the output should contain "my_lib/gl"
    And the output should contain "my_lib/tool"

  Scenario: List no installed libraries
    When I run `skippy lib:list`
    Then the output should contain "No libraries installed"

  Scenario: Use a library component
    Given a file named ".skippy/libs/my_lib/skippy.json" with:
      """
      {
        "library": true,
        "name": "My Shiny Library",
        "version": "1.2.3"
      }
      """
    And a file named ".skippy/libs/my_lib/modules/gl.rb" with:
      """
      module SkippyLib
        module GL
        end
      end # module
      """
    And a file named ".skippy/libs/my_lib/modules/gl/container.rb" with:
      """
      Sketchup.require "modules/gl/control"

      module SkippyLib
        module GL
          class Container < Control
          end
        end
      end # module
      """
    When I run `skippy lib:use my_lib/gl`
    Then a file named "src/hello_world/vendor/my_lib/gl.rb" should exist
    And a file named "src/hello_world/vendor/my_lib/gl.rb" should contain:
      """
      module Example::HelloWorld
        module GL
        end
      end # module
      """
    And a file named "src/hello_world/vendor/my_lib/gl/container.rb" should exist
    And a file named "src/hello_world/vendor/my_lib/gl/container.rb" should contain:
      """
      Sketchup.require "hello_world/vendor/my_lib/gl/control"

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
          "my_lib/gl"
        ]
      }
      """
