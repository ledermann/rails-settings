# Settings Gem/Plugin for Rails

[![Build Status](https://secure.travis-ci.org/ledermann/rails-settings.png)](http://travis-ci.org/ledermann/rails-settings)

Settings is a gem/plugin that makes managing a table of key/value pairs easy. Think of it like a Hash stored in you database, that uses simple ActiveRecord like methods for manipulation. Keep track of any setting that you don't want to hard code into your rails app. You can store any kind of object: Strings, numbers, arrays, or any object which can be noted as YAML.


## Requirements

Rails 2.3.x, 3.1.x or 3.2.x (due to an [issue with Rails caching](https://github.com/rails/rails/pull/2010) it does not work properly with Rails 3.0.x)

Tested with Ruby 1.8.7 and 1.9.3


## Installation

Include the gem in your Gemfile

    gem 'ledermann-rails-settings', :require => 'rails-settings'

or install as a plugin:

    ./script/plugin install git://github.com/ledermann/rails-settings.git


You have to create the table used by the Settings model by using this migration:

    class CreateSettingsTable < ActiveRecord::Migration
      def self.up
        create_table :settings, :force => true do |t|
          t.string  :var,         :null => false
          t.text    :value
          t.integer :target_id
          t.string  :target_type, :limit => 30
          t.timestamps
        end

        add_index :settings, [ :target_type, :target_id, :var ], :unique => true
      end

      def self.down
        drop_table :settings
      end
    end
    
Now update your database with:

    rake db:migrate

## Usage

The syntax is easy. First, lets create some settings to keep track of:

    Settings.admin_password = 'supersecret'
    Settings.date_format    = '%m %d, %Y'
    Settings.cocktails      = ['Martini', 'Screwdriver', 'White Russian']
    Settings.foo            = 123
    Settings.credentials    = { :username => 'tom', :password => 'secret' }

Now lets read them back:

    Settings.foo
    # => 123

Changing an existing setting is the same as creating a new setting:

    Settings.foo = 'super duper bar'

For changing an existing setting which is a Hash, you can merge new values with existing ones:

    Settings.merge! :credentials, :password => 'topsecret'
    Settings.credentials
    # => { :username => 'tom', :password => 'topsecret' }

Decide you dont want to track a particular setting anymore?

    Settings.destroy :foo
    Settings.foo
    # => nil

Want a list of all the settings (including defaults)?

    Settings.all
    # => { 'admin_password' => 'super_secret', 'date_format' => '%m %d, %Y' }

You need name spaces and want a list of settings for a give name space? Just choose your prefered named space delimiter and use Settings.all like this:

    Settings['preferences.color'] = :blue
    Settings['preferences.size'] = :large
    Settings['license.key'] = 'ABC-DEF'
    Settings.all('preferences.')
    # => { 'preferences.color' => :blue, 'preferences.size' => :large }

Settings may be bound to any existing ActiveRecord object. Define this association like this:

    class User < ActiveRecord::Base
      has_settings
    end

Then you can set/get a setting for a given user instance just by doing this:

    user = User.find(123)
    user.settings.color = :red
    user.settings.color
    # => :red
    
    user.settings.all
    # => { "color" => :red }


Set defaults for certain settings of your app.  This will cause the defined settings to return with the
specified value even if they are not in the database.  Make a new file in config/initializers/settings.rb
with the following:

    Settings.defaults[:foo] = 'footastic'
  
Now even if the database is completely empty, you app will have some intelligent defaults:

    Settings.foo
    # => 'footastic'

Defaults can be defined on the model level, too:

    User.settings.foo = 'bar'
    User.find(123).settings.foo
    # => 'bar'

If the setting doesn't exist on the object or the model, you'll get the default, as expected:

    Settings.defaults[:some_default] = 'foo'
    
    User.settings.some_default
    # => 'foo'
    
    User.find(123).settings.some_default
    # => 'foo'


I you want to find users having or not having some settings, there are named scopes for this:

    User.with_settings
    # returns a scope of users having any setting
    
    User.with_settings_for('color')
    # returns a scope of users having a 'color' setting
  
    User.without_settings
    # returns a scope of users having no setting at all (means user.settings.all == {})
    
    User.without_settings('color')
    # returns a scope of users having no 'color' setting (means user.settings.color == nil)

For better performance, you can enable caching, e.g.:

    Settings.cache = ActiveSupport::Cache::MemoryStore.new
    Settings.cache_options = { :expires_in => 5.minutes }

That's all there is to it! Enjoy!