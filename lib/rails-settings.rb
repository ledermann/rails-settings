require 'ostruct'

require 'app/models/setting_object'
require 'rails-settings/base'
require 'rails-settings/scopes'

ActiveRecord::Base.class_eval do
  def self.has_settings(keys)
    class_attribute :default_settings
    self.default_settings = {}

    keys.each_pair do |key, defaults|
      raise ArgumentError unless key.is_a?(Symbol)
      raise ArgumentError unless defaults.nil? || defaults.is_a?(Hash)

      self.default_settings[key] = defaults
    end

    include RailsSettings::Base   unless self.include?(RailsSettings::Base)
    include RailsSettings::Scopes unless self.include?(RailsSettings::Scopes)
  end
end
