module RailsSettings
  module Base
    def self.included(base)
      base.class_eval do
        # Use a custom SettingObject class if there is any
        setting_object_class_name = begin
          "#{base.name}SettingObject" if Module.const_get("#{base.name}SettingObject")
        rescue NameError
          'RailsSettings::SettingObject'
        end
        
        has_many :setting_objects,
                 :as         => :target,
                 :autosave   => true,
                 :dependent  => :delete_all,
                 :class_name => setting_object_class_name
        
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
        
        def settings?(var=nil)
          if var.nil?
            setting_objects.any? { |setting_object| !setting_object.marked_for_destruction? && setting_object.value.present? }
          else
            settings(var).value.present?
          end
        end
      end
    end
  end
end
