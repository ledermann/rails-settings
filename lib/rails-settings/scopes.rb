module RailsSettings
  module Scopes
    def self.included(base)
      base.class_eval do
        scope :with_settings, lambda {
          joins(:setting_object)
        }

        scope :with_settings_for, lambda { |key|
          raise ArgumentError unless key.is_a?(Symbol)
          
          joins(:setting_object).
          where("settings.value LIKE '%#{yaml_fragment(key)}%'")
        }

        scope :without_settings, lambda {
          joins("LEFT JOIN settings ON
                  (settings.target_id = #{self.table_name}.#{self.primary_key} AND
                   settings.target_type = '#{self.base_class.name}')").
          where('settings.id IS NULL')
        }

        scope :without_settings_for, lambda { |key|
          raise ArgumentError unless key.is_a?(Symbol)
          
          joins("LEFT JOIN settings ON
                  (settings.target_id = #{self.table_name}.#{self.primary_key} AND
                   settings.target_type = '#{self.base_class.name}') AND
                   settings.value LIKE '%#{yaml_fragment(key)}%'").
          where('settings.id IS NULL')
        }
        
        # Check a serialized Hash for a given key
        # 
        # Remember:
        #   { :one => 1, :two => 2 }.to_yaml
        #   => "---\n:one: 1\n:two: 2\n"
        def self.yaml_fragment(key)
          "\n:#{key}: "
        end
      end
    end
  end
end