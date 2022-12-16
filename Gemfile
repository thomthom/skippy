# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in skippy.gemspec
gemspec

# Even if Bundler is told to install only one of these groups, it appear to
# process the gem requirements of all groups. This would cause Bundler to fail
# on CI builds where the Ruby version was older than what some of the gems in
# the skipped groups required. To work around that the groups are conditionally
# evaluated such that in CI environment only the minimal set of gems are
# processed by Bundler.
IS_CI_ENVIRONMENT = ENV.key?('CI')

group :development do
  gem 'debase', '~> 0.2'         # VSCode debugging
  gem 'pry'                      # TODO: What was this used for?
  gem 'ruby-debug-ide', '~> 0.7' # VSCode debugging
  gem 'solargraph'               # VSCode IDE support
end unless IS_CI_ENVIRONMENT

group :test do
  gem 'minitest', '~> 5.15.0' # Regression in 5.16.0 causing failure on Ruby 2.7
  gem 'minitest-reporters', '~> 1.5'
  gem 'rake', '~> 13.0'
  gem 'webmock', '~> 3.1'
end

group :integration_test do
  gem 'aruba', '~> 2.0'
end

# group :documentation do
#   gem 'commonmarker', '~> 0.23'
#   gem 'yard', '~> 0.9'
# end unless IS_CI_ENVIRONMENT

group :analysis do
  gem 'rubocop', '~> 1.0', require: false
  gem 'rubocop-minitest', '~> 0.15', require: false
  gem 'rubocop-performance', '~> 1.0', require: false
  gem 'rubocop-rake', '~> 0.6', require: false
end unless IS_CI_ENVIRONMENT
