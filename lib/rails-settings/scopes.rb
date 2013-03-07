module RailsSettings
  module Scopes
    def self.included(base)
      base.class_eval do
        scope :with_settings, lambda {
          joins(:setting_objects).
          uniq
        }

        scope :with_settings_for, lambda { |var|
          raise ArgumentError unless var.is_a?(Symbol)

          joins("JOIN settings ON (settings.target_id = #{self.table_name}.#{self.primary_key} AND
                                   settings.target_type = '#{self.base_class.name}') AND
                                   settings.var = '#{var}'")
        }

        scope :without_settings, lambda {
          joins("LEFT JOIN settings ON
                  (settings.target_id = #{self.table_name}.#{self.primary_key} AND
                   settings.target_type = '#{self.base_class.name}')").
          where('settings.id IS NULL')
        }

        scope :without_settings_for, lambda { |var|
          raise ArgumentError unless var.is_a?(Symbol)

          joins("LEFT JOIN settings ON (settings.target_id = #{self.table_name}.#{self.primary_key} AND
                           settings.target_type = '#{self.base_class.name}') AND
                           settings.var = '#{var}'").
          where('settings.id IS NULL')
        }
      end
    end
  end
end
