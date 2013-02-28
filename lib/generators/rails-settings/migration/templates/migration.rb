class RailsSettingsMigration < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.text       :value,  :null => false
      t.references :target, :null => false, :polymorphic => true
      t.timestamps
    end
    add_index :settings, [ :target_type, :target_id ], :unique => true
  end

  def self.down
    drop_table :settings
  end
end