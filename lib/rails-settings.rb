require 'ostruct'

require 'app/models/setting_object'
require 'rails-settings/base'
require 'rails-settings/scopes'

ActiveRecord::Base.class_eval do
  def self.has_settings(var, defaults=nil)
    raise ArgumentError unless var.is_a?(Symbol)
    raise ArgumentError unless defaults.nil? || defaults.is_a?(Hash)
    
    unless self.respond_to?(:default_settings)
      class_attribute :default_settings
      self.default_settings = {}
    end
    self.default_settings[var] = defaults || {}

    include RailsSettings::Base   unless self.include?(RailsSettings::Base)
    include RailsSettings::Scopes unless self.include?(RailsSettings::Scopes)
  end
end
