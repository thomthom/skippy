Feature: Libraries

  Developers should be able to use third-party libraries in their extensions.

  Scenario: Install a new library from local disk
    Given I use a fixture named "my_project"
    And a file named "./temp/my_lib/skippy.json" with:
      """
      {
        "library": true,
        "name": "my-lib",
        "version": "1.2.3"
      }
      """
    And an empty directory "./temp/my_lib/modules"
    When I run `skippy lib:install ./temp/my_lib`
    Then a file named ".skippy/libs/my-lib/skippy.json" should exist
    And a directory named ".skippy/libs/my-lib/modules" should exist
    And a file named "skippy.json" should contain json fragment:
      """
      {
        "libraries": [
          {
            "name": "my-lib",
            "version": "1.2.3",
            "source": "./temp/my_lib"
          }
        ]
      }
      """
    And the output should contain "Installed library: my-lib (1.2.3)"

  Scenario: Install a new library from local disk twice
    Given I use a fixture named "my_project"
    And a file named "./temp/my_lib/skippy.json" with:
      """
      {
        "library": true,
        "name": "my-lib",
        "version": "1.2.3"
      }
      """
    And an empty directory "./temp/my_lib/modules"
    When I run `skippy lib:install ./temp/my_lib`
    And I run `skippy lib:install ./temp/my_lib`
    Then a file named ".skippy/libs/my-lib/skippy.json" should exist
    And a directory named ".skippy/libs/my-lib/modules" should exist
    And a file named "skippy.json" should contain json fragment:
      """
      {
        "libraries": [
          {
            "name": "my-lib",
            "version": "1.2.3",
            "source": "./temp/my_lib"
          }
        ]
      }
      """
    And the output should contain "Installed library: my-lib (1.2.3)"

  Scenario: Uninstall library
    Given I use a fixture named "project_with_lib"
    When I run `skippy lib:uninstall my-lib`
    And I run `skippy lib:list`
    Then the output should contain "Uninstalled library: my-lib (1.2.3)"
    And the directory ".skippy/libs/my-lib" should not exist
    And the directory "src/hello_world/vendor/my-lib" should not exist
    And a file named "skippy.json" should contain json fragment:
      """
      {
        "libraries": [
          {
            "name": "my-other-lib",
            "version": "2.4.3",
            "source": "./temp/my-other-lib"
          }
        ]
      }
      """
    And a file named "skippy.json" should contain json fragment:
      """
      {
        "modules": [
          "my-other-lib/something"
        ]
      }
      """


  Scenario: List installed libraries
    Given I use a fixture named "my_project"
    And a file named ".skippy/libs/my-lib/skippy.json" with:
      """
      {
        "library": true,
        "name": "my-lib",
        "version": "1.2.3"
      }
      """
    And an empty file named ".skippy/libs/my-lib/modules/command.rb"
    And an empty file named ".skippy/libs/my-lib/modules/geom.rb"
    And an empty file named ".skippy/libs/my-lib/modules/gl.rb"
    And an empty file named ".skippy/libs/my-lib/modules/gl/cache.rb"
    And an empty file named ".skippy/libs/my-lib/modules/gl/container.rb"
    And an empty file named ".skippy/libs/my-lib/modules/gl/control.rb"
    And an empty file named ".skippy/libs/my-lib/modules/tool.rb"
    When I run `skippy lib:list`
    Then the output should contain "my-lib/command"
    And the output should contain "my-lib/geom"
    And the output should contain "my-lib/gl"
    And the output should contain "my-lib/tool"

  Scenario: List no installed libraries
    Given I use a fixture named "my_project"
    When I run `skippy lib:list`
    Then the output should contain "No libraries installed"

  Scenario: Use a library component
    Given I use a fixture named "my_project"
    And a file named ".skippy/libs/my-lib/skippy.json" with:
      """
      {
        "library": true,
        "name": "my-lib",
        "version": "1.2.3"
      }
      """
    And a file named ".skippy/libs/my-lib/modules/gl.rb" with:
      """
      module SkippyLib
        module GL
        end
      end # module
      """
    And a file named ".skippy/libs/my-lib/modules/gl/container.rb" with:
      """
      Sketchup.require "modules/gl/control"

      module SkippyLib
        module GL
          class Container < Control
          end
        end
      end # module
      """
    When I run `skippy lib:use my-lib/gl`
    Then a file named "src/hello_world/vendor/my-lib/gl.rb" should exist
    And a file named "src/hello_world/vendor/my-lib/gl.rb" should contain:
      """
      module Example::HelloWorld
        module GL
        end
      end # module
      """
    And a file named "src/hello_world/vendor/my-lib/gl/container.rb" should exist
    And a file named "src/hello_world/vendor/my-lib/gl/container.rb" should contain:
      """
      Sketchup.require "hello_world/vendor/my-lib/gl/control"

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
          "my-lib/gl"
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

