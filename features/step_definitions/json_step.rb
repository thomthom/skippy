# frozen_string_literal: true

require 'json'

Then(/^a file named "([^"]*)" should contain json fragment:$/) do |file, json_string|
  expect(file).to be_an_existing_file

  content = read(file).join("\n")
  actual = JSON.parse(content)

  expected = JSON.parse(json_string)

  included = (expected.to_a - actual.to_a).empty?
  unless included
    actual_json = JSON.pretty_generate(actual)
    raise ArgumentError, "#{file} did not include expected JSON fragment. Actual:\n#{actual_json}"
  end
end
