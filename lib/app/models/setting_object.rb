module RailsSettings
  class SettingObject < ActiveRecord::Base
    self.table_name = 'settings'

    belongs_to :target, :polymorphic => true

    validates_presence_of :var, :value, :target_type
    validate do
      unless _target_class.default_settings[var.to_sym]
        errors.add(:var, "#{var} is not defined!")
      end
    end

    serialize :value, Hash

    REGEX_SETTER = /\A([a-z]\w+)=\Z/i
    REGEX_GETTER = /\A([a-z]\w+)\Z/i

    def respond_to?(method_name, include_priv=false)
      super || method_name.to_s =~ REGEX_SETTER
    end

    def method_missing(method_name, *args, &block)
      if block_given?
        super
      else
        if method_name.to_s =~ REGEX_SETTER && args.size == 1
          _set_value($1, args.first)
        elsif method_name.to_s =~ REGEX_GETTER && args.size == 0
          _get_value($1)
        else
          super
        end
      end
    end

  private
    def _get_value(name)
      value[name] || _target_class.default_settings[var.to_sym][name]
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

    def update(*)
      # Patch ActiveRecord to save serialized attributes only if they are changed
      # https://github.com/rails/rails/blob/3-2-stable/activerecord/lib/active_record/attribute_methods/dirty.rb#L70
      super(changed) if changed?
    end
  end
end
