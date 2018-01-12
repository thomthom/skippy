require 'json'

Then(/^(?:the|a) (?:file|directory) named like "([^"]*)" should( not)? exist$/) do |pattern, negate|
  items = cd('.') {
    Dir.glob(pattern)
  }
  if negate
    expect(items).to be_empty
  else
    expect(items.size).to eq(1)
  end
end
