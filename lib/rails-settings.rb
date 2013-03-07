require 'rails-settings/setting_object'
require 'rails-settings/configuration'
require 'rails-settings/base'
require 'rails-settings/scopes'

ActiveRecord::Base.class_eval do
  def self.has_settings(*args, &block)
    RailsSettings::Configuration.new(*args.unshift(self), &block)

    include RailsSettings::Base   unless self.include?(RailsSettings::Base)
    include RailsSettings::Scopes unless self.include?(RailsSettings::Scopes)
  end
end

