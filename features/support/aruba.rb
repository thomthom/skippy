require 'aruba/cucumber'

=begin
Aruba.configure do |config|
  # Use aruba working directory
  config.home_directory = File.join(config.root_directory, config.working_directory, 'HomeDir')
end

Aruba.configure do |config|
  puts %(The default value is "#{config.home_directory}")
  puts %(The root value is "#{config.root_directory}")
  puts %(The working value is "#{config.working_directory}")
  puts %(The current is "#{File.expand_path('.')}")
  puts %(The ENV HOME is "#{ENV['HOME']}")
  puts %(The current is "#{File.expand_path('~/HelloWorld')}")
end
=end
