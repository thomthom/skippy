# rubocop:disable all

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'skippy/version'

Gem::Specification.new do |spec|
  spec.name          = 'skippy'
  spec.version       = Skippy::VERSION
  spec.authors       = ['Thomas Thomassen']
  spec.email         = ['thomas@thomthom.net']

  spec.summary       = %q{CLI development tool for SketchUp extensions.}
  spec.description   = %q{Automate common tasks for SketchUp extension development, including managing library dependencies.}
  spec.homepage      = 'https://github.com/thomthom/skippy'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'thor', '~> 0.19'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  # TODO(thomthom): Need to lock to 2.3 because 2.4 fails with the custom
  # aruba build.
  spec.add_development_dependency 'cucumber', '~> 2.3.0'
  spec.add_development_dependency 'aruba', '~> 0.14.1'
end
