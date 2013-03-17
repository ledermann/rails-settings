Version 2.0.2 (2013-03-17)

- Changed database schema to allow NULL for column `value` to fix serialization
  bug with MySQL. Thanks to @steventen for pointing this out in issue #31.

  IMPORTANT: The migration generator of version 2.0.0 and 2.0.1 was broken. If
             you use MySQL it's required to update your database schema like
             this:

             ```ruby
             class FixSettings < ActiveRecord::Migration
               def up
                 change_column :settings, :value, :text, :null => true
               end

               def down
                 change_column :settings, :value, :text, :null => false
               end
             end
             ```


Version 2.0.1 (2013-03-08)

- Added mass assignment security by protecting all regular attributes


Version 2.0.0 (2013-03-07)

- Complete rewrite
- New DSL (see README.md)
- No global defaults anymore. Defaults are defined per ActiveRecord class
- No more storing defaults in the database
- Rails >= 3.1 needed (Rails 2.3 not supported anymore)
- Threadsafe
- Switched to RSpec for testing


Version 1.2.1 (2013-02-09)

- Quick and dirty fix for design flaw in target scope implementation (thanks to Yves-Eric Martin)
- Use Thread.current instead of cattr_accessor to be threadsafe
- Code cleanup


Version 1.2.0 (2012-07-21)

- Added model-level settings (thanks to Jim Ryan)


Version 1.1.0 (2012-06-01)

- Added caching (thanks to Matthew McEachen)


Version 1.0.1 (2011-11-05)

- Gemspec: Fixed missing dependency


Version 1.0.0 (2011-11-05)

- Conversion from Plugin to Gem
- Destroying false values (thanks to @Pavling)
- Testing with Travis
