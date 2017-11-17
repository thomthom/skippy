Feature: Commands

  Developers should be able to create custom skippy commands for their project.

  Scenario: List available commands with project commands
    Given a file named "skippy.json" with:
      """
      {
        "name": "Hello World",
        "version": "1.2.3"
      }
      """
    And a file named "skippy/commands/example.rb" with:
      """
      class Hello < Skippy::Command

        desc 'world PERSON', 'Oh, hi there!'
        def world(person)
          say "Hello #{person}"
        end
        default_command(:world)

        desc 'universe', 'Greets the universe in general'
        def universe
          say "DARK IN HERE, ISN'T IT?"
        end

      end
      """
    When I run `skippy`
    Then the output should contain "Skippy version"
    And the output should contain "Available commands:"
    And the output should contain "lib:install"
    And the output should contain "lib:list"
    And the output should contain "lib:use"
    And the output should contain "hello:world"
    And the output should contain "hello:universe"

  Scenario: List available commands with project commands with errors
    Given a file named "skippy.json" with:
      """
      {
        "name": "Hello World",
        "version": "1.2.3"
      }
      """
    And a file named "skippy/commands/example.rb" with:
      """
      require 'no_such_file'

      class Hello < Skippy::Command

        desc 'world PERSON', 'Oh, hi there!'
        def world(person)
          say "Hello #{person}"
        end
        default_command(:world)

      end
      """
    When I run `skippy`
    Then the output should contain "Skippy version"
    And the output should contain "Available commands:"
    And the output should contain "lib:install"
    And the output should contain "lib:list"
    And the output should contain "lib:use"
    And the output should contain "Error loading: skippy/commands/example.rb"
