Version 2.0.0 (WIP)

- Complete rewrite
- New API (not finished yet)
- Rails 3.2 only
- Threadsafe
- No more storing defaults in the database
- Define defaults per ActiveRecord class, no global defaults anymore
- Testing with RSpec
- Based on OpenStruct
- Store settings using `before_save` callback


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