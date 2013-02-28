module RailsSettings
  module Scopes
    def self.included(base)
      base.class_eval do
        scope :with_settings, lambda {
          joins(:setting_object)
        }

        scope :with_settings_for, lambda { |key|
          joins(:setting_object).
          where("settings.value LIKE '%#{key}: %'")
        }

        scope :without_settings, lambda {
          joins("LEFT JOIN settings ON (settings.target_id = #{self.table_name}.#{self.primary_key} AND
                                        settings.target_type = '#{self.base_class.name}')").
          where('settings.id IS NULL')
        }

        scope :without_settings_for, lambda { |key|
          joins("LEFT JOIN settings ON (settings.target_id = #{self.table_name}.#{self.primary_key} AND
                                        settings.target_type = '#{self.base_class.name}') AND
                                        settings.value LIKE '%#{key}: %'").
          where('settings.id IS NULL')
        }
      end
    end
  end
end