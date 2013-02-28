require 'ostruct'

require 'rails-settings/setting_object'
require 'rails-settings/base'
require 'rails-settings/scopes'

ActiveRecord::Base.class_eval do
  def self.has_settings(defaults=nil)
    class_attribute :default_settings
    self.default_settings = defaults || {}

    include RailsSettings::Base
    include RailsSettings::Scopes
  end
end
