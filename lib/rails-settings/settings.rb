class Settings < ActiveRecord::Base
  class SettingNotFound < RuntimeError; end
  
  cattr_accessor :defaults
  self.defaults = {}.with_indifferent_access

  # cache must follow the contract of ActiveSupport::Cache. Defaults to no-op.
  cattr_accessor :cache
  self.cache = ActiveSupport::Cache::NullStore.new

  # options passed to cache.fetch() and cache.write(). example: {:expires_in => 5.minutes}
  cattr_accessor :cache_options
  self.cache_options = {}

  def self.cache_key(var_name)
    [target_id, target_type, var_name].compact.join("::")
  end

  # Support old plugin
  if defined?(SettingsDefaults::DEFAULTS)
    self.defaults = SettingsDefaults::DEFAULTS.with_indifferent_access
  end
  
  #get or set a variable with the variable as the called method
  def self.method_missing(method, *args)
    if self.respond_to?(method)
      super
    else
      method_name = method.to_s
    
      #set a value for a variable
      if method_name =~ /=$/
        var_name = method_name.gsub('=', '')
        value = args.first
        self[var_name] = value
    
      #retrieve a value
      else
        self[method_name]
      
      end
    end
  end
  
  #destroy the specified settings record
  def self.destroy(var_name)
    var_name = var_name.to_s
    begin
      target(var_name).destroy
      cache.delete(cache_key(var_name))
      true
    rescue NoMethodError
      raise SettingNotFound, "Setting variable \"#{var_name}\" not found"
    end
  end

  def self.delete_all(conditions = nil)
    cache.clear
    super
  end

  #retrieve all settings as a hash (optionally starting with a given namespace)
  def self.all(starting_with=nil)
    options = starting_with ? { :conditions => "var LIKE '#{starting_with}%'"} : {}
    vars = target_scoped.find(:all, {:select => 'var, value'}.merge(options))
    
    result = {}
    vars.each do |record|
      result[record.var] = record.value
    end
    defaults = @@defaults.select{ |k, v| k =~ /^#{starting_with}/ }
    defaults = Hash[defaults] if defaults.is_a?(Array)
    defaults.merge(result).with_indifferent_access
  end
  
  #get a setting value by [] notation
  def self.[](var_name)
    cache.fetch(cache_key(var_name), cache_options) do
      if var = target(var_name)
        var.value
      else
        if target_id.nil?
          @@defaults[var_name.to_s]
        else
          target_type.constantize.settings[var_name.to_s]
        end
      end
    end
  end
  
  #set a setting value by [] notation
  def self.[]=(var_name, value)
    record = target_scoped.find_or_initialize_by_var(var_name.to_s)
    record.value = value
    record.save!
    cache.write(cache_key(var_name), value, cache_options)
    value
  end
  
  def self.merge!(var_name, hash_value)
    raise ArgumentError unless hash_value.is_a?(Hash)
    
    old_value = self[var_name] || {}
    raise TypeError, "Existing value is not a hash, can't merge!" unless old_value.is_a?(Hash)
    
    new_value = old_value.merge(hash_value)
    self[var_name] = new_value if new_value != old_value
    
    new_value
  end

  def self.target(var_name)
    target_scoped.find_by_var(var_name.to_s)
  end
  
  #get the value field, YAML decoded
  def value
    YAML::load(self[:value])
  end
  
  #set the value field, YAML encoded
  def value=(new_value)
    self[:value] = new_value.to_yaml
  end
  
  def self.target_scoped
    Settings.scoped_by_target_type_and_target_id(target_type, target_id)
  end
  
  #Deprecated!
  def self.reload # :nodoc:
    self
  end
  
  def self.target_id
    nil
  end

  def self.target_type
    nil
  end
end
