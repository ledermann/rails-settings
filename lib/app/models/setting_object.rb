module RailsSettings
  class SettingObject < ActiveRecord::Base
    self.table_name = 'settings'

    belongs_to :target, :polymorphic => true

    validates_presence_of :var, :value, :target_type
    validate do
      unless target_class.default_settings[var.to_sym]
        errors.add(:var, "#{var} is not defined!")
      end
    end

    serialize :value, Hash

    def update_attributes(attributes)
      merge_value(attributes)
      self.value_changed? ? super(:value => self.value) : true
    end
    
    def update_attributes!(attributes)
      merge_value(attributes)
      self.value_changed? ? super(:value => self.value) : true
    end

    def method_missing(method_name, *args, &block)
      if m = method_name.to_s.match(/(.*)=$/)
        # Setter
        self.value_will_change!
        self.value[m[1]] = args.first
      else
        # Getter
        self.value[method_name.to_s] || target_class.default_settings[var.to_sym][method_name.to_s]
      end
    end

  private
    def target_class
      target_type.constantize
    end
    
    def merge_value(attributes)
      self.value = self.value.merge(attributes.stringify_keys)
    end
  end
end
