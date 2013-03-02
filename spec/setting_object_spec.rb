require 'spec_helper'

describe RailsSettings::SettingObject do
  let(:user) { User.create! :name => 'Mr. Pink' }
  let(:setting_object) { RailsSettings::SettingObject.new :var => 'dashboard', :target => user }

  it "should return nil for unknown keys" do
    setting_object.foo.should eq(nil)
    setting_object.bar.should eq(nil)
  end

  it "should return defaults" do
    setting_object.theme.should eq('blue')
    setting_object.view.should eq('monthly')
    setting_object.filter.should eq(false)
  end
  
  it "should set and return keys" do
    setting_object.theme = 'pink'
    setting_object.foo = 42
    setting_object.bar = 'hello'

    setting_object.theme.should eq('pink')
    setting_object.foo.should eq(42)
    setting_object.bar.should eq('hello')
  end

  it "should store to hash" do
    setting_object.foo = 42
    setting_object.bar = 'hello'
    
    setting_object.value.should eq({:foo => 42, :bar => 'hello'}.with_indifferent_access)
  end
  
  it "should save" do
    setting_object.foo = 42
    setting_object.bar = 'hello'
    setting_object.save!
    
    setting_object.should_not be_new_record
    setting_object.id.should_not be_zero
  end
  
  it "should not validate for unknown var" do
    setting_object.var = "unknown-var"
    
    setting_object.should_not be_valid
    setting_object.errors[:var].should be_present
  end
end
