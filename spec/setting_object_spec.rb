require 'spec_helper'

describe RailsSettings::SettingObject do
  let(:user) { User.create! :name => 'Mr. Pink' }
  let(:setting_object) { RailsSettings::SettingObject.new :var => 'dashboard', :target => user }

  describe "Getter and Setter" do
    it "should return nil for unknown attribute" do
      setting_object.foo.should eq(nil)
      setting_object.bar.should eq(nil)
    end

    it "should return defaults" do
      setting_object.theme.should eq('blue')
      setting_object.view.should eq('monthly')
      setting_object.filter.should eq(false)
    end

    it "should store to hash" do
      setting_object.foo = 42
      setting_object.bar = 'hello'

      setting_object.value.should eq({'foo' => 42, 'bar' => 'hello'})
    end

    it "should set and return attributes" do
      setting_object.theme = 'pink'
      setting_object.foo = 42
      setting_object.bar = 'hello'

      setting_object.theme.should eq('pink')
      setting_object.foo.should eq(42)
      setting_object.bar.should eq('hello')
    end
  end

  describe "update_attributes" do
    it 'should save' do
      setting_object.update_attributes('foo' => 42).should be_true
      setting_object.reload

      setting_object.foo.should eq(42)
    end

    it "should not save for unchanged attributes" do
      setting_object.theme = 'white'
      setting_object.save!
      setting_object.reload

      setting_object.should_not_receive(:save)
      setting_object.update_attributes :theme => 'white'
    end

    it "should not save for blank Hash" do
      setting_object.should_not_receive(:save)
      setting_object.update_attributes({}).should be_true
    end
  end

  describe "update_attributes!" do
    it 'should save' do
      setting_object.update_attributes!('foo' => 42).should be_true
      setting_object.reload

      setting_object.foo.should eq(42)
    end

    it "should not save for unchanged attributes" do
      setting_object.theme = 'white'
      setting_object.save!
      setting_object.reload
      
      setting_object.should_not_receive(:save)
      setting_object.update_attributes! :theme => 'white'
    end

    it "should not save for blank Hash" do
      setting_object.should_not_receive(:save!)
      setting_object.update_attributes!({}).should be_true
    end
  end

  describe "save!" do
    it "should save" do
      setting_object.foo = 42
      setting_object.bar = 'hello'
      setting_object.save!

      setting_object.should_not be_new_record
      setting_object.id.should_not be_zero
    end
  end

  describe "validation" do
    it "should not validate for unknown var" do
      setting_object.var = "unknown-var"

      setting_object.should_not be_valid
      setting_object.errors[:var].should be_present
    end
  end
end
