# Bundler Research

## Debug Helper

```ruby
class Object
  def methods!
    methods.sort - Object.methods
  end
end

class Object; def methods!; methods.sort - Object.methods; end; end
```

## Obtaining the Runtime

```ruby
require 'bundler'
runtime = Bundler.setup
```

## Runtime methods

```
irb(main):011:0> runtime.methods!
=> [
  :cache,
  :chdir,
  :clean,
  :const_get_safely,
  :current_dependencies,
  :default_bundle_dir,
  :default_gemfile,
  :default_lockfile,
  :dependencies,
  :digest,
  :ensure_same_dependencies,
  :filesystem_access,
  :gems,
  :in_bundle?,
  :lock,
  :major_deprecation,
  :md5_available?,
  :pretty_dependency,
  :print_major_deprecations!,
  :prune_cache,
  :pwd,
  :requested_specs,
  :require,
  :requires,
  :root,
  :set_bundle_environment,
  :set_env,
  :setup,
  :specs,
  :trap,
  :with_clean_git_env,
  :write_to_gemfile
]
```

## Example Gemfile

```ruby
source 'https://rubygems.org'

group :development do
  gem 'rubocop'
  gem 'rubocop-sketchup', '~> 0.10.2'
  gem 'sketchup-api-stubs', '>= 0.6.1'
  gem 'skippy'
end
```

### Runtime dependencies

```ruby
irb(main):024:0> runtime.dependencies.map(&:name)
=> ["rubocop", "rubocop-sketchup", "sketchup-api-stubs", "skippy"]
```

### Runtime specs

```ruby
irb(main):021:0> runtime.specs.map(&:full_name)
=> ["ast-2.4.0", "bundler-2.0.2", "git-1.5.0", "jaro_winkler-1.5.3", "naturally-2.2.0", "parallel-1.17.0", "parser-2.6.4.1", "rainbow-3.0.0", "ruby-progressbar-1.10.1", "unicode-display_width-1.6.0", "rubocop-0.74.0", "rubocop-sketchup-0.10.2", "sketchup-api-stubs-0.6.1", "thor-0.20.3", "skippy-0.4.1.a"]
```

### Runtime gems

```ruby
irb(main):022:0> runtime.gems.map(&:full_name)
=> ["ast-2.4.0", "bundler-2.0.2", "git-1.5.0", "jaro_winkler-1.5.3", "naturally-2.2.0", "parallel-1.17.0", "parser-2.6.4.1", "rainbow-3.0.0", "ruby-progressbar-1.10.1", "unicode-display_width-1.6.0", "rubocop-0.74.0", "rubocop-sketchup-0.10.2", "sketchup-api-stubs-0.6.1", "thor-0.20.3", "skippy-0.4.1.a"]
```

## Bundler

```ruby
λ irb
irb(main):001:0> require 'bundler'
=> true
```

### Definition

```ruby
irb(main):002:0> Bundler.definition
Traceback (most recent call last):
        9: from C:/Ruby25-x64/bin/irb.cmd:19:in `<main>'
        8: from (irb):2
        7: from C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/bundler-2.0.2/lib/bundler.rb:134:in `definition'
        6: from C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/bundler-2.0.2/lib/bundler.rb:66:in `configure'
        5: from C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/bundler-2.0.2/lib/bundler.rb:535:in `configure_gem_home_and_path'
        4: from C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/bundler-2.0.2/lib/bundler.rb:554:in `configure_gem_home'
        3: from C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/bundler-2.0.2/lib/bundler.rb:80:in `bundle_path'
        2: from C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/bundler-2.0.2/lib/bundler.rb:233:in `root'
        1: from C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/bundler-2.0.2/lib/bundler.rb:237:in `rescue in root'
Bundler::GemfileNotFound (Could not locate Gemfile or .bundle/ directory)
irb(main):003:0>'
```

#### Definition Dependencies

```ruby
irb(main):033:0> Bundler.definition.dependencies.map(&:name)
=> ["rubocop", "rubocop-sketchup", "sketchup-api-stubs", "skippy"]

irb(main):034:0> Bundler.definition.dependencies.first.class
=> Bundler::Dependency
```

#### Definition Dependency Methods (?)

```ruby
=> [:all_sources, :all_sources=, :autorequire, :current_env?, :current_platform?, :encode_with, :gem_platforms, :gemfile, :groups, :groups=, :latest_version?, :match?, :matches_spec?, :matching_specs, :merge, :name=, :platforms, :prerelease=, :prerelease?, :pretty_print, :requirement, :requirements_list, :runtime?, :should_include?, :source, :source=, :specific?, :to_lock, :to_spec, :to_specs, :to_yaml_properties, :type]
```

```ruby
irb(main):038:0> Bundler.definition.dependencies.first.matching_specs.size
=> 1

irb(main):039:0> Bundler.definition.dependencies.first.matching_specs.class
=> Array

irb(main):040:0> Bundler.definition.dependencies.first.matching_specs.first.class
=> Gem::Specification

irb(main):041:0> Bundler.definition.dependencies.first.matching_specs.first.name
=> "rubocop"

irb(main):042:0> Bundler.definition.dependencies.first.matching_specs.first.version
=> #<Gem::Version "0.74.0">
```

```ruby
> {"rubocop"=><Bundler::Dependency type=:runtime name="rubocop" requirements=">= 0">, "rubocop-sketchup"=><Bundler::Dependency type=:runtime name="rubocop-sketchup" requirements="~> 0.10.2">, "sketchup-api-stubs"=><Bundler::Dependency type=:runtime name="sketchup-api-stubs" requirements=">= 0.6.1">, "skippy"=><Bundler::Dependency type=:runtime name="skippy" requirements=">= 0">}
```

```ruby
irb(main):065:0> Bundler.definition.locked_gems.dependencies
=> {"rubocop"=><Bundler::Dependency type=:runtime name="rubocop" requirements=">= 0">, "rubocop-sketchup"=><Bundler::Dependency type=:runtime name="rubocop-sketchup" requirements="~> 0.10.2">, "sketchup-api-stubs"=><Bundler::Dependency type=:runtime name="sketchup-api-stubs" requirements=">= 0.6.1">, "skippy"=><Bundler::Dependency type=:runtime name="skippy" requirements=">= 0">}
```

```ruby
irb(main):070:0> Bundler.definition.locked_gems.specs.map(&:full_name)
=> ["ast-2.4.0", "git-1.5.0", "jaro_winkler-1.5.3", "naturally-2.2.0", "parallel-1.17.0", "parser-2.6.4.1", "rainbow-3.0.0", "rubocop-0.74.0", "rubocop-sketchup-0.10.2", "ruby-progressbar-1.10.1", "sketchup-api-stubs-0.6.1", "skippy-0.4.1.a", "thor-0.20.3", "unicode-display_width-1.6.0"]
```

```ruby
irb(main):003:0> Bundler.definition.lockfile
=> #<Pathname:C:/Users/Thomas/SourceTree/sketchup-extension-vscode-project/Gemfile.lock>

irb(main):004:0> Bundler.definition.lockfile.exist?

=> false
irb(main):005:0>
```

```ruby
specs = Bundler.definition.locked_gems.specs
specs.first.methods!
[:__materialize__, :dependencies, :full_name, :git_version, :identifier, :match_platform, :platform, :remote, :remote=, :satisfies?, :source, :source=, :to_lock, :version]
specs.first.version
#<Gem::Version "2.7.0">
specs.first.source
#<Bundler::Source::Rubygems:0x34425860 rubygems repository https://rubygems.org/ or installed locally>
specs.first.identifier
#<struct Bundler::LazySpecification::Identifier name="addressable", version=#<Gem::Version "2.7.0">, source=#<Bundler::Source::Rubygems:0x34425860 rubygems repository https://rubygems.org/ or installed locally>, platform="ruby", dependencies=[<Gem::Dependency type=:runtime name="public_suffix" requirements=">= 2.0.2, < 5.0">]>
```
