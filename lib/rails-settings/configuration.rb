module RailsSettings
  class Configuration
    def initialize(*args, &block)
      @default_options = args.extract_options!
      validate_options @default_options
      klass = args.shift
      keys = args

      raise ArgumentError unless klass

      @klass = klass
      @klass.class_attribute :setting_keys
      @klass.setting_keys = {}

      if block_given?
        yield(self)
      else
        keys.each { |k| key(k) }
      end

      raise ArgumentError.new('has_settings: No keys defined') if @klass.setting_keys.empty?
    end

    def key(name, options={})
      validate_name name
      validate_options options
      options = @default_options.merge(options)

      @klass.setting_keys[name] = {
        :default_value => (options[:defaults] || {}).stringify_keys.freeze,
        :class_name => (options[:class_name] || 'RailsSettings::SettingObject')
      }
    end

    private

    def validate_name(name)
      raise ArgumentError.new("has_settings: Symbol expected, but got a #{name.class}") unless name.is_a?(Symbol)
    end

    def validate_options(options)
      valid_options = [:defaults, :class_name]
      options.each do |key, value|
        unless valid_options.include?(key)
          raise ArgumentError.new("has_settings: Invalid option #{key}")
        end
      end
      if options[:class_name] && !options[:class_name].constantize.ancestors.include?(RailsSettings::SettingObject)
        raise ArgumentError.new("has_settings: #{options[:class_name]} must be a subclass of RailsSettings::SettingObject")
      end
    end
  end
end
