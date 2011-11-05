# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rails-settings/version'

Gem::Specification.new do |s|
  s.name        = 'ledermann-rails-settings'
  s.version     = RailsSettings::VERSION
  s.authors     = ['Georg Ledermann']
  s.email       = ['mail@georg-ledermann.de']
  s.homepage    = 'https://github.com/ledermann/rails-settings'
  s.summary     = %q{Settings management for ActiveRecord objects}
  s.description = %q{Ruby Gem that makes managing a table of key/value pairs easy. Think of it like a Hash stored in you database, that uses simple ActiveRecord like methods for manipulation.}

  s.rubyforge_project = 'ledermann-rails-settings'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_dependency 'activerecord', '>= 2.3'
end
