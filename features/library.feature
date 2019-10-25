Feature: Libraries

  Developers should be able to use third-party libraries in their extensions.

  @obsolete
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

  @obsolete
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

  @obsolete
  Scenario: Install a new library from git source
    Given I use a fixture named "my_project"
    When I run `skippy lib:install ../../../fixtures/git-lib`
    Then the output should contain "Installed library: test-lib (1.3.0)"
    And a file named like ".skippy/libs/git-lib_local_*/skippy.json" should exist
    And a directory named like ".skippy/libs/git-lib_local_*/modules" should exist
    And a file named "skippy.json" should contain json fragment:
      """
      {
        "libraries": [
          {
            "name": "test-lib",
            "version": "1.3.0",
            "source": "../../../fixtures/git-lib"
          }
        ]
      }
      """

  @obsolete
  Scenario: Install a new library from git source with spesific version
    Given I use a fixture named "my_project"
    When I run `skippy lib:install ../../../fixtures/git-lib --version=1.2.3`
    Then the output should contain "Installed library: test-lib (1.2.3)"
    And a directory named ".skippy/libs" should exist
    And a file named like ".skippy/libs/git-lib_local_*/skippy.json" should exist
    And a directory named like ".skippy/libs/git-lib_local_*/modules" should exist
    And a file named "skippy.json" should contain json fragment:
      """
      {
        "libraries": [
          {
            "name": "test-lib",
            "version": "1.2.3",
            "source": "../../../fixtures/git-lib",
            "requirement": "1.2.3"
          }
        ]
      }
      """

  @obsolete
  Scenario: Install from a source that is not a Skippy Library
    Given I use a fixture named "my_project"
    And a file named "./temp/my_lib/skippy.json" with:
      """
      {
        "name": "my-lib",
        "version": "1.2.3"
      }
      """
    When I run `skippy lib:install ./temp/my_lib`
    And the output should contain "Not a Skippy Library"

  @obsolete
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

  @obsolete
  Scenario: Uninstall all libraries
    Given I use a fixture named "project_with_lib"
    When I run `skippy lib:uninstall my-lib`
    And I run `skippy lib:uninstall my-other-lib`
    And I run `skippy lib:list`
    Then the output should contain "Uninstalled library: my-lib (1.2.3)"
    And the output should contain "Uninstalled library: my-other-lib (2.4.3)"
    And the directory ".skippy/libs/my-lib" should not exist
    And the directory "src/hello_world/vendor" should not exist
    And a file named "skippy.json" should contain json fragment:
      """
      {
        "libraries": []
      }
      """
    And a file named "skippy.json" should contain json fragment:
      """
      {
        "modules": []
      }
      """

  @obsolete
  Scenario: Uninstall library from git source
    Given I use a fixture named "project_with_lib"
    When I run `skippy lib:install ../../../fixtures/git-lib`
    And I run `skippy lib:list`
    And I run `skippy lib:uninstall test-lib`
    And I run `skippy lib:list`
    Then the output should contain "Uninstalled library: test-lib (1.3.0)"
    And the directory named like ".skippy/libs/git-lib_local_*" should not exist
    And the directory "src/hello_world/vendor/test-lib" should not exist
    And a file named "skippy.json" should contain json fragment:
      """
      {
        "libraries": [
          {
            "name": "my-lib",
            "version": "1.2.3",
            "source": "./temp/my_lib"
          },
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
          "my-lib/command",
          "my-other-lib/something"
        ]
      }
      """

  @obsolete
  Scenario: Update an installed library from local disk
    Given I use a fixture named "project_with_lib"
    And a file named "./temp/my_lib/skippy.json" with:
      """
      {
        "library": true,
        "name": "my-lib",
        "version": "5.0.1"
      }
      """
    And a file named "./temp/my_lib/modules/command.rb" with:
      """
      module SkippyLib
        class Command
          VERSION = "5.0.1"
        end
      end # module
      """
    When I run `skippy lib:install ./temp/my_lib`
    Then a file named ".skippy/libs/my-lib/skippy.json" should exist
    And a directory named ".skippy/libs/my-lib/modules" should exist
    And a file named "skippy.json" should contain json fragment:
      """
      {
        "libraries": [
          {
            "name": "my-lib",
            "version": "5.0.1",
            "source": "./temp/my_lib"
          },
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
          "my-lib/command",
          "my-other-lib/something"
        ]
      }
      """
    And the file named "src/hello_world/vendor/my-lib/command.rb" should contain:
      """
      module Example::HelloWorld
        class Command
          VERSION = "5.0.1"
        end
      end # module
      """
    And the output should contain "Installed library: my-lib (5.0.1)"

  @obsolete
  Scenario: Update a library from git source
    Given I use a fixture named "my_project"
    When I run `skippy lib:install ../../../fixtures/git-lib --version="1.2.3"`
    Then I run `skippy lib:use test-lib/command`
    Then I run `skippy lib:install ../../../fixtures/git-lib --version="1.3.0"`
    Then the output should contain "Installed library: test-lib (1.3.0)"
    And a directory named ".skippy/libs" should exist
    And a file named "skippy.json" should contain json fragment:
      """
      {
        "libraries": [
          {
            "name": "test-lib",
            "version": "1.3.0",
            "source": "../../../fixtures/git-lib",
            "requirement": "1.3.0"
          }
        ]
      }
      """
    And the file named "src/hello_world/vendor/test-lib/command.rb" should contain:
      """
      module Example::HelloWorld
        class Command
          # Version 1.3.0
        end
      end # module
      """

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

  Scenario: Use a library component
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

  Scenario: Remove a module from a git source library
    Given I use a fixture named "my_project"
    When I run `skippy lib:install ../../../fixtures/git-lib --version="1.3.0"`
    Then I run `skippy lib:use test-lib/command`
    Then I run `skippy lib:remove test-lib/command`
    Then the output should contain "Removed module: test-lib/command"
    And a file named "src/hello_world/vendor/test-lib/command.rb" should not exist
    And a file named "skippy.json" should contain json fragment:
      """
      {
        "modules": []
      }
      """

