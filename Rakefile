# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |task|
  task.libs << 'test'
  # task.libs << "test/helpers"
  task.libs << 'lib'
  task.test_files = FileList['test/**/*_test.rb']
  # Turning off because Rake 11 >= turns warning on by default.
  # TODO: Clean up the warnings coming from this project and enable.
  task.warning = false
end

task default: :test
