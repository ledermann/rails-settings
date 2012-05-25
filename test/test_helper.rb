require 'rubygems'

require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'test/unit'

require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false

class User < ActiveRecord::Base
  has_settings
  belongs_to :account
end

class Account < ActiveRecord::Base
  has_one :user
end

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :settings do |t|
      t.string :var, :null => false
      t.text :value, :null => true
      t.integer :target_id, :null => true
      t.string :target_type, :limit => 30, :null => true
      t.timestamps
    end
    add_index :settings, [ :target_type, :target_id, :var ], :unique => true
    
    create_table :users do |t|
      t.string :name
      t.belongs_to :account
      t.timestamps
    end

    create_table :accounts do |t|
      t.string :login
    end
  end
end

puts "Testing with ActiveRecord #{ActiveRecord::VERSION::STRING}"
