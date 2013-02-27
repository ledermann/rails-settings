module RailsSettings
  class SettingObject < ActiveRecord::Base
    self.table_name = 'settings'
    
    belongs_to :target, :polymorphic => true

    validates_presence_of :value, :target_id, :target_type
    attr_accessible :value

    serialize :value, Hash
  end
end
