# Settings gem for Rails

Complete rewrite

# Example

```ruby
class User < ActiveRecord::Base
  has_settings :dashboard, :theme => 'blue', :view => 'monthly', :filter => false
  has_settings :calendar, :scope => 'company'
end
```

Beware: Work in progress!