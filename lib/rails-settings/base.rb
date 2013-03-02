module RailsSettings
  module Base
    def self.included(base)
      base.class_eval do
        has_many :setting_objects,
                 :as         => :target,
                 :autosave   => true,
                 :dependent  => :delete_all,
                 :class_name => 'RailsSettings::SettingObject'

        def settings(var)
          raise ArgumentError unless var.is_a?(Symbol)
          raise ArgumentError.new("Unknown key: #{var}") unless self.class.default_settings[var]
          
          setting_objects.detect { |s| s.var == var.to_s } || setting_objects.build(:var => var.to_s)
        end
        
        def settings=(value)
          if value.nil?
            setting_objects.each(&:mark_for_destruction)
          else
            raise ArgumentError
          end
        end
      end
    end
  end
end
