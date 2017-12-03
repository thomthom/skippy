source 'https://rubygems.org'

# Specify your gem's dependencies in skippy.gemspec
gemspec

group :development do
  # Original fork with bug-fix. Appear to be gone now.
  # gem 'aruba', git: 'https://github.com/daynix/aruba.git', branch: 'd-win-fix'
  # Backup fork of the bug fix:
  gem 'aruba', git: 'https://github.com/thomthom/aruba.git',
               branch: 'd-win-fix'
  # TODO: This might be a newer fix:
  # gem 'aruba', git: 'https://github.com/rbld/aruba.git',
  #              branch: 'aruba-win-fix'
  gem 'rubocop', '~> 0.51.0', require: false
  gem 'webmock', '~> 3.1'
end
