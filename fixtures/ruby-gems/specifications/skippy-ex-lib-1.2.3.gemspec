# -*- encoding: utf-8 -*-
# stub: skippy-ex-lib 1.2.3 ruby lib

Gem::Specification.new do |s|
  s.name = "skippy-ex-lib".freeze
  s.version = "1.2.3"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Thomas Thomassen".freeze]
  s.date = "2021-10-09"
  s.description = "Stub Skippy lib. skippy-ex-lib".freeze
  s.email = ["thomas@thomthom.net".freeze]
  s.homepage = "https://github.com/thomthom/skippy".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Stub Skippy lib. skippy-ex-lib".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<skippy-dep-lib>.freeze, ["~> 4.5"])
  else
    s.add_dependency(%q<skippy-dep-lib>.freeze, ["~> 4.5"])
  end
end
