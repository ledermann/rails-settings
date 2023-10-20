require 'rails/generators'
require 'rails/generators/migration'

module RailsSettings
  class MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    desc 'Generates migration for rails-settings'
    source_root File.expand_path('../templates', __FILE__)

    def create_migration_file
      migration_template 'migration.rb',
                         'db/migrate/rails_settings_migration.rb'
    end

    def self.next_migration_number(dirname)
      if timestamped_migrations?
        Time.now.utc.strftime('%Y%m%d%H%M%S')
      else
        '%.3d' % (current_migration_number(dirname) + 1)
      end
    end

    def self.timestamped_migrations?
      (ActiveRecord::Base.respond_to?(:timestamped_migrations) && ActiveRecord::Base.timestamped_migrations) ||
      (ActiveRecord.respond_to?(:timestamped_migrations) && ActiveRecord.timestamped_migrations)
    end
  end
end
