module RailsSettings
  module Scopes
    def self.included(base)
      base.class_eval do
        scope :with_settings, lambda {
          joins("INNER JOIN settings ON #{settings_join_condition}").
          uniq
        }

        scope :with_settings_for, lambda { |var|
          raise ArgumentError unless var.is_a?(Symbol)
          joins("INNER JOIN settings ON #{settings_join_condition} AND settings.var = '#{var}'")
        }

        scope :without_settings, lambda {
          joins("LEFT JOIN settings ON #{settings_join_condition}").
          where('settings.id IS NULL')
        }

        scope :without_settings_for, lambda { |var|
          raise ArgumentError unless var.is_a?(Symbol)
          joins("LEFT JOIN settings ON  #{settings_join_condition} AND settings.var = '#{var}'").
          where('settings.id IS NULL')
        }

        def self.settings_join_condition
          "settings.target_id   = #{table_name}.#{primary_key} AND
           settings.target_type = '#{base_class.name}'"
        end
      end
    end
  end
end
