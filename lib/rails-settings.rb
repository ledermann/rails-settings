require 'ostruct'

require 'rails-settings/setting_object'
require 'rails-settings/base'
require 'rails-settings/scopes'

ActiveRecord::Base.class_eval do
  def self.has_settings(defaults=nil)
    class << self
      attr_accessor :default_settings
    end
    self.default_settings = defaults || {}

    include RailsSettings::Base
    include RailsSettings::Scopes
  end
end
