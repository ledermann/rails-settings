class Settings < ActiveRecord::Base
  class SettingNotFound < RuntimeError; end
  
  cattr_accessor :defaults
  @@defaults = {}.with_indifferent_access
  
  # Support old plugin
  if defined?(SettingsDefaults::DEFAULTS)
    @@defaults = SettingsDefaults::DEFAULTS.with_indifferent_access
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
      true
    rescue NoMethodError
      raise SettingNotFound, "Setting variable \"#{var_name}\" not found"
    end
  end

  #retrieve all settings as a hash (optionally starting with a given namespace)
  def self.all(starting_with=nil)
    options = starting_with ? { :conditions => "var LIKE '#{starting_with}%'"} : {}
    vars = target_scoped.find(:all, {:select => 'var, value'}.merge(options))
    
    result = {}
    vars.each do |record|
      result[record.var] = record.value
    end
    result.with_indifferent_access
  end
  
  #get a setting value by [] notation
  def self.[](var_name)
    if var = target(var_name)
      var.value
    else
      @@defaults[var_name.to_s]
    end
  end
  
  #set a setting value by [] notation
  def self.[]=(var_name, value)
    record = target_scoped.find_or_initialize_by_var(var_name.to_s)
    record.value = value
    record.save!
    
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