require 'rails-settings/setting_object'
require 'rails-settings/configuration'
require 'rails-settings/base'
require 'rails-settings/scopes'

ActiveRecord::Base.class_eval do
  def self.has_settings(*args, &block)
    RailsSettings::Configuration.new(*args.unshift(self), &block)

    include RailsSettings::Base
    extend RailsSettings::Scopes
  end
end

