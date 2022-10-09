# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in skippy.gemspec
gemspec

group :development do
  gem 'pry'
  gem 'debase', '~> 0.2'         # VSCode debugging
  gem 'ruby-debug-ide', '~> 0.7' # VSCode debugging
  gem 'solargraph'               # VSCode IDE support
end

group :test do
  gem 'aruba', '~> 2.0'
  gem 'minitest', '~> 5.15.0' # Regression in 5.16.0 causing failure on Ruby 2.7
  gem 'minitest-reporters', '~> 1.5'
  gem 'rake', '~> 13.0'
  gem 'webmock', '~> 3.1'
end

# group :documentation do
#   gem 'commonmarker', '~> 0.23'
#   gem 'yard', '~> 0.9'
# end

group :analysis do
  gem 'rubocop', '~> 1.0', require: false
  gem 'rubocop-minitest', '~> 0.15', require: false
  gem 'rubocop-performance', '~> 1.0', require: false
  gem 'rubocop-rake', '~> 0.6', require: false
end

group :ci do
  gem 'appveyor-worker', '~> 0.2', require: false
end
