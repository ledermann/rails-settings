# Settings gem for Rails

[![Build Status](https://secure.travis-ci.org/ledermann/rails-settings.png)](http://travis-ci.org/ledermann/rails-settings)

Handling settings for ActiveRecord objects by storing them as serialized Hash in a separate database table. Optional: Defaults and Namespaces.

**BEWARE: WORK IN PROGRESS!**


## Requirements

Rails 3.1.x or 3.2.x  
Ruby 1.8.7, 1.9.3 or 2.0.0


# Example

### Define Settings for a model with default values

Without defaults:

```ruby
class User < ActiveRecord::Base
  has_settings :dashboard, :calendar
end
```

With defaults:

```ruby
class User < ActiveRecord::Base
  has_settings do |s|
    s.key :dashboard, :defaults => { :theme => 'blue', :view => 'monthly', :filter => false }
    s.key :calendar,  :defaults => { :scope => 'company'}
  end
end
```

With customized object, e.g. for validation:

```ruby
class Project < ActiveRecord::Base
  has_settings :info, :class_name => 'ProjectSettingObject'
end

class ProjectSettingObject < RailsSettings::SettingObject
  validate do
    unless self.owner_name.present? && self.owner_name.is_a?(String)
      errors.add(:base, "Owner name is missing")
    end
  end
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