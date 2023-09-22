module RailsSettings
  class Configuration
    def initialize(*args, &block)
      options = args.extract_options!
      klass = args.shift
      keys = args

      raise ArgumentError unless klass

      @klass = klass

      if options[:persistent]
        unless @klass.methods.include?(:default_settings)
          @klass.class_attribute :default_settings
        end
      else
        @klass.class_attribute :default_settings
      end

      @klass.class_attribute :setting_object_class_name
      @klass.default_settings ||= {}
      @klass.setting_object_class_name =
        options[:class_name] || 'RailsSettings::SettingObject'

      if block_given?
        yield(self)
      else
        keys.each { |k| key(k) }
      end

      if @klass.default_settings.blank?
        raise ArgumentError.new('has_settings: No keys defined')
      end
    end

    def key(name, options = {})
      unless name.is_a?(Symbol)
        raise ArgumentError.new(
                "has_settings: Symbol expected, but got a #{name.class}",
              )
      end
      unless options.blank? || (options.keys == [:defaults])
        raise ArgumentError.new(
                "has_settings: Option :defaults expected, but got #{options.keys.join(', ')}",
              )
      end
      @klass.default_settings[name] = (
        options[:defaults] || {}
      ).stringify_keys.freeze
    end
  end
end
