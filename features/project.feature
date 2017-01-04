Feature: Project

  Developers should be able to create skippy projects that aids their extension
  development.

  Scenario: Create new project with default template
    When I run `skippy new Example::HelloWorld`
    Then a file named "skippy.json" should exist
    Then a file named "src/hello_world.rb" should exist
    Then a file named "src/hello_world/main.rb" should exist
    Then a file named "src/hello_world/extension.json" should exist
    Then a file named "skippy/example.rb" should exist

  Scenario: Create new project with custom template
    When I run `skippy new Example::WebDialog --template=webdialog`
    Then a file named "skippy.json" should exist
    Then a file named "src/web_dialog.rb" should exist
    Then a file named "src/web_dialog/main.rb" should exist
    Then a file named "src/web_dialog/extension.json" should exist
    Then a file named "src/web_dialog/html/dialog.html" should exist
    Then a file named "skippy/example.rb" should exist