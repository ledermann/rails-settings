require 'rubygems'

gem 'activesupport', '< 3'
gem 'activerecord', '< 3'

require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'test/unit'

require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

class User < ActiveRecord::Base
  has_settings
end

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :settings do |t|
      t.string :var, :null => false
      t.text   :value, :null => true
      t.integer :target_id, :null => true
      t.string :target_type, :limit => 30, :null => true
      t.timestamps
    end
    add_index :settings, [ :target_type, :target_id, :var ], :unique => true
    
    create_table :users do |t|
      t.string :name
    end
  end
end