module RailsSettings
  class SettingObject < ActiveRecord::Base
    self.table_name = 'settings'

    belongs_to :target, :polymorphic => true

    validates_presence_of :var, :target_type
    validate do
      errors.add(:value, "Invalid setting value") unless value.is_a? Hash

      unless _target_class.default_settings[var.to_sym]
        errors.add(:var, "#{var} is not defined!")
      end
    end

    serialize :value, Hash

    if RailsSettings.can_protect_attributes?
      # attr_protected can not be used here because it touches the database which is not connected yet.
      # So allow no attributes and override <tt>#sanitize_for_mass_assignment</tt>
      attr_accessible
    end

    REGEX_SETTER = /\A([a-z]\w*)=\Z/i
    REGEX_GETTER = /\A([a-z]\w*)\Z/i

    def respond_to?(method_name, include_priv=false)
      super || method_name.to_s =~ REGEX_SETTER || _setting?(method_name)
    end

    def method_missing(method_name, *args, &block)
      if block_given?
        super
      else
        if attribute_names.include?(method_name.to_s.sub('=',''))
          super
        elsif method_name.to_s =~ REGEX_SETTER && args.size == 1
          _set_value($1, args.first)
        elsif method_name.to_s =~ REGEX_GETTER && args.size == 0
          _get_value($1)
        else
          super
        end
      end
    end

  protected
    if RailsSettings.can_protect_attributes?
      # Simulate attr_protected by removing all regular attributes
      def sanitize_for_mass_assignment(attributes, role = nil)
        attributes.except('id', 'var', 'value', 'target_id', 'target_type', 'created_at', 'updated_at')
      end
    end

  private
    def _get_value(name)
      if value[name].nil?
        default_value = _get_default_value(name)
        _deep_dup(default_value)
      else
        value[name]
      end
    end
  
    def _get_default_value(name)
      default_value = _target_class.default_settings[var.to_sym][name]
  
      if default_value.respond_to?(:call)
        default_value.call(target)
      else
        default_value
      end
    end
  
    def _deep_dup(nested_hashes_and_or_arrays)
      Marshal.load(Marshal.dump(nested_hashes_and_or_arrays))
    end

    def _set_value(name, v)
      if value[name] != v
        value_will_change!

        if v.nil?
          value.delete(name)
        else
          value[name] = v
        end
      end
    end

    def _target_class
      target_type.constantize
    end

    def _setting?(method_name)
      _target_class.default_settings[var.to_sym].keys.include?(method_name.to_s)
    end
  end
end
