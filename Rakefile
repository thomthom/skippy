require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  # Turning off because Rake 11 >= turns warning on by default.
  # TODO: Clean up the warnings coming from this project and enable.
  t.warning = false
end

task default: :test
