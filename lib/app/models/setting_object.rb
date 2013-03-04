module RailsSettings
  class SettingObject < ActiveRecord::Base
    self.table_name = 'settings'

    belongs_to :target, :polymorphic => true

    validates_presence_of :var, :value, :target_type
    validate do
      unless target_class.default_settings[var.to_sym]
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
      if method_name.to_s =~ REGEX_SETTER
        # Setter
        if self.value[$1] != args.first
          self.value_will_change!
          
          if args.first.nil?
            self.value.delete($1)
          else
            self.value[$1] = args.first
          end
        end
      elsif method_name.to_s =~ REGEX_GETTER
        # Getter
        self.value[$1] || target_class.default_settings[var.to_sym][$1]
      else
        super
      end
    end

  private
    def target_class
      target_type.constantize
    end

    def update(*)
      # Patch ActiveRecord to save serialized attributes only if they are changed
      # https://github.com/rails/rails/blob/3-2-stable/activerecord/lib/active_record/attribute_methods/dirty.rb#L70
      super(changed) if changed?
    end
  end
end
