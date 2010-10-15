class <%= class_name %> < ActiveRecord::Migration
  def self.up
    create_table :settings, :force => true do |t|
      t.string :var, :null => false
      t.text   :value, :null => true
      t.integer :target_id, :null => true
      t.string :target_type, :limit => 30, :null => true
      t.timestamps
    end
    
    add_index :settings, [ :target_type, :target_id, :var ], :unique => true
  end

  def self.down
    drop_table :settings
  end
end
