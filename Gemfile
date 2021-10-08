# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in skippy.gemspec
gemspec

group :development do
  gem 'pry'
  gem 'rubocop', '~> 1.0', require: false
  gem 'rubocop-minitest', '~> 0.15', require: false
  gem 'rubocop-performance', '~> 1.0', require: false
  gem 'rubocop-rake', '~> 0.6', require: false
  gem 'webmock', '~> 3.1'
end

group :ci do
  gem 'appveyor-worker', '~> 0.2', require: false
end
