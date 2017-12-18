Feature: Project

  Developers should be able to create skippy projects that aid their extension
  development.

  Scenario: Create new project with default template
    When I run `skippy new Example::HelloWorld`
    Then the output should contain "Project for Example::HelloWorld created."
    And a file named "skippy.json" should exist
    And a file named "src/Ex_HelloWorld.rb" should exist
    And a file named "src/Ex_HelloWorld/main.rb" should exist
    And a file named "src/Ex_HelloWorld/extension.json" should exist
    And a file named "skippy/commands/example.rb" should exist

  Scenario: Create new project with custom template
    When I run `skippy new Example::WebDialog --template=webdialog`
    Then the output should contain "Project for Example::WebDialog created."
    And a file named "skippy.json" should exist
    And a file named "src/Ex_WebDialog.rb" should exist
    And a file named "src/Ex_WebDialog/main.rb" should exist
    And a file named "src/Ex_WebDialog/extension.json" should exist
    And a file named "src/Ex_WebDialog/html/dialog.html" should exist
    And a file named "skippy/commands/example.rb" should exist
