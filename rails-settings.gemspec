# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-settings/version'

Gem::Specification.new do |gem|
  gem.name = 'ledermann-rails-settings'
  gem.version = RailsSettings::VERSION
  gem.licenses = ['MIT']
  gem.authors = ['Georg Ledermann']
  gem.email = ['georg@ledermann.dev']
  gem.description = 'Settings gem for Ruby on Rails'
  gem.summary =
    'Ruby gem to handle settings for ActiveRecord instances by storing them as serialized Hash in a separate database table. Namespaces and defaults included.'
  gem.homepage = 'https://github.com/ledermann/rails-settings'
  gem.required_ruby_version = '>= 3.2'

  gem.files = `git ls-files`.split($/)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'activerecord', '>= 6.1'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'coveralls_reborn'
  gem.add_development_dependency 'simplecov', '>= 0.11.2'
end
