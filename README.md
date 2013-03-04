# Settings gem for Rails

[![Build Status](https://secure.travis-ci.org/ledermann/rails-settings.png)](http://travis-ci.org/ledermann/rails-settings)

Handling settings for ActiveRecord objects (with defaults).

**BEWARE: WORK IN PROGRESS!**


## Requirements

Rails 3.1.x or 3.2.x  
Ruby 1.8.7, 1.9.3 or 2.0.0


# Example

### Define Settings for a model with default values

```ruby
class User < ActiveRecord::Base
  has_settings :dashboard => { :theme => 'blue', :view => 'monthly', :filter => false },
               :calendar  => { :scope => 'company'}
end
```

### Set settings for a given object

```ruby
user = User.find(1)
user.settings(:dashboard).theme = 'black'
user.settings(:calendar).scope = 'all'
user.settings(:calendar).display = 'daily'
user.save!
```

or

```ruby
user = User.find(1)
user.settings(:dashboard).update_attributes! :theme => 'black'
user.settings(:calendar).update_attributes! :scope => 'all', :display => 'dialy'
```


### Get settings

```ruby
user = User.find(1)
user.settings(:dashboard).theme
# => 'black

user.settings(:dashboard).view
# => 'monthly'  (it's default)

user.settings(:calendar).scope
# => 'all'
```


## Installation

Include the gem in your Gemfile:

```ruby
gem 'ledermann-rails-settings', :github => 'ledermann/rails-settings', :branch => 'rewrite', :require => 'rails-settings'
```

Generate and run the migration:

```shell
rails g rails_settings:migration
rake db:migrate
```


## License

MIT License  
Copyright (c) 2013 Georg Ledermann

This gem is a complete rewrite of [rails-settings](https://github.com/Squeegy/rails-settings) by [Alex Wayne](https://github.com/Squeegy)