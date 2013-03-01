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
          raise ArgumentError.new("Unknown key: #{var}") unless self.class.default_settings[var]
          
          @_setting_structs ||= begin
            result = self.class.default_settings.dup
            
            setting_objects.each do |setting_object|
              result[setting_object.var.to_sym] = result[setting_object.var.to_sym].merge(setting_object.value)
            end
            
            result.keys.each do |key|
              result[key] = OpenStruct.new(result[key])
            end
            result
          end
          
          @_setting_structs[var]
        end
        
        def settings_loaded?
          @_setting_structs.present?
        end
        
        def settings=(value)
          if value.nil?
            setting_objects.each(&:mark_for_destruction)
            @_setting_structs = nil
          else
            raise
          end
        end
        
        def reset_settings
          setting_objects.reset
          @_setting_structs = nil
        end
        
        def update_settings!(var, hash)
          if settings_loaded?
            setting_object = setting_objects.detect { |s| s.var.to_sym == var }
          else
            # No need to load all setting_objects, so just find the right one
            setting_object = setting_objects.where(:var => var).first
          end
          
          if hash.present? && hash != self.class.default_settings[var]
            setting_object ||= setting_objects.build
            setting_object.var = var.to_s
            setting_object.value = setting_object.value.merge(hash)
            @_setting_structs[var] = OpenStruct.new(setting_object.value) if settings_loaded?
            setting_object.save!
          elsif setting_object
            setting_object.destroy
          end
        end

        before_save do
          @_setting_structs.each_pair do |var,value|
            hash = value.marshal_dump
            setting_object = setting_objects.detect { |s| s.var.to_sym == var }
            
            if hash.present? && hash != self.class.default_settings[var]
              setting_object ||= setting_objects.build
              setting_object.var = var.to_s
              setting_object.value = hash
            elsif setting_object
              setting_object.mark_for_destruction
            end
          end if settings_loaded?
        end
      end
    end
  end
end
