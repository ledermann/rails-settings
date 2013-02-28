module RailsSettings
  module Base
    def self.included(base)
      base.class_eval do
        has_one :setting_object, :as => :target, :dependent => :delete, :class_name => 'RailsSettings::SettingObject', :autosave => true

        def settings
          @_settings_struct ||= OpenStruct.new self.class.default_settings.merge(setting_object ? setting_object.value : {})
        end

        def settings=(value)
          hash = value.is_a?(OpenStruct) ? value.marshal_dump : value
          @_settings_struct = OpenStruct.new self.class.default_settings.merge(hash || {})
        end

        before_save do
          if @_settings_struct
            hash = @_settings_struct.marshal_dump
            if hash.present? && hash != self.class.default_settings
              build_setting_object unless setting_object
              setting_object.value = hash
            elsif self.setting_object
              self.setting_object.mark_for_destruction
            end
          end
        end
      end
    end
  end
end
