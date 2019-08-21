module RailsSettings
  # In Rails 4, attributes can be protected by using the gem `protected_attributes`
  # In Rails 5, protecting attributes is obsolete (there are `StrongParameters` only)
  def self.can_protect_attributes?
    defined?(ProtectedAttributes)
  end
end

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
