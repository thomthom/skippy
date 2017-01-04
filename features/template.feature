Feature: Templates

  Developers should be able to add, remove or list available project templates.

  Scenario: List available templates
    When I run `skippy template:list`
    Then the output should contain "standard"
    And the output should contain "webdialog"
