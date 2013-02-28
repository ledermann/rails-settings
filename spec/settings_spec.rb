require 'spec_helper'
setup_db

describe "Getter/Setter" do
  before :each do
    @account = Account.new :subdomain => 'foo'
  end

  it "should handle method syntax" do
    @account.settings.premium = true
    @account.settings.fee = 42.5

    @account.settings.premium.should eq(true)
    @account.settings.fee.should eq(42.5)
  end

  it "should handle Hash syntax" do
    @account.settings = { :premium => true, :fee => 42.5 }
    
    @account.settings.premium.should eq(true)
    @account.settings.fee.should eq(42.5)
  end

  it "should handle OpenStruct" do
    @account.settings = OpenStruct.new(:premium => true, :fee => 42.5)
    
    @account.settings.premium.should eq(true)
    @account.settings.fee.should eq(42.5)
  end

  it "should return nil for not existing key" do
    @account.settings.foo.should eq(nil)
  end
end

describe 'Objects' do
  context 'without defaults' do
    before :each do
      @account = Account.new :subdomain => 'foo'
    end

    it 'should have blank settings' do
      @account.settings.should eq(OpenStruct.new)
    end

    it 'should not add settings' do
      @account.save!
      RailsSettings::SettingObject.count.should eq(0)
    end

    it "should save object with settings" do
      @account.settings.premium = true
      @account.settings.fee = 42.5
      @account.save!

      @account.reload
      @account.settings.premium.should eq(true)
      @account.settings.fee.should eq(42.5)
      
      RailsSettings::SettingObject.count.should eq(1)
      RailsSettings::SettingObject.first.value.should == { :premium => true, :fee => 42.5 }
    end
  end

  context 'with defaults' do
    before :each do
      @user = User.new :name => 'Mr. Brown'
    end

    it "should return class defaults" do
      User.default_settings.should eq(:theme => 'blue', :newsletter => true)
    end

    it 'should have default settings' do
      @user.settings.theme.should eq('blue')
      @user.settings.newsletter.should eq(true)
    end
    
    it 'should have default settings after changing one' do
      @user.settings.theme = 'red'
      
      @user.settings.theme.should eq('red')
      @user.settings.newsletter.should eq(true)
    end

    it "should overwrite settings" do
      @user.settings.theme = 'brown'
      @user.settings.newsletter = false
      @user.save!

      @user.reload
      @user.settings.theme.should eq('brown')
      @user.settings.newsletter.should eq(false)

      RailsSettings::SettingObject.count.should eq(1)
      RailsSettings::SettingObject.first.value.should == { :theme => 'brown', :newsletter => false }
    end

    it "should merge settings with defaults" do
      @user.settings.theme = 'brown'
      @user.save!

      @user.reload
      @user.settings.theme.should eq('brown')
      @user.settings.newsletter.should eq(true)

      RailsSettings::SettingObject.count.should eq(1)
      RailsSettings::SettingObject.first.value.should == { :theme => 'brown', :newsletter => true }
    end
  end
end

describe "Object with settings" do
  before :each do
    @user = User.create! :name => 'Mr. White', :settings => { :theme => 'white' }
  end

  it "should have one setting object" do
    RailsSettings::SettingObject.count.should eq(1)
  end
  
  it "should destroy settings with nil" do
    @user.settings = nil
    @user.save!
    
    RailsSettings::SettingObject.count.should eq(0)
  end
  
  it "should destroy settings with empty hash" do
    @user.settings = {}
    @user.save!
    
    RailsSettings::SettingObject.count.should eq(0)
  end

  it "should destroy settings with defaults" do
    @user.settings = { :theme => 'blue', :newsletter => true }
    @user.save!
    
    RailsSettings::SettingObject.count.should eq(0)
  end
end

describe 'scopes' do
  before :each do
    @user1 = User.create! :name => 'Mr. White', :settings => OpenStruct.new(:theme => 'white')
    @user2 = User.create! :name => 'Mr. Pink',  :settings => {}
    @user3 = User.create! :name => 'Mr. Blond', :settings => nil
    @user4 = User.create! :name => 'Mr. Blue'
  end

  it "should find objects with existing settings" do
    User.with_settings.all.should eq([@user1])
  end

  it "should find objects with settings for key" do
    User.with_settings_for(:theme).all.should eq([@user1])
    User.with_settings_for(:them).all.should eq([])
    User.with_settings_for(:foo).all.should eq([])
  end

  it "should records without settings" do
    User.without_settings.all.should eq([@user2, @user3, @user4])
  end

  it "should records without settings for key" do
    User.without_settings_for(:foo).all.should eq([@user1, @user2, @user3, @user4])
    User.without_settings_for(:theme).all.should eq([@user2, @user3, @user4])
  end
end

describe "Subclass" do
  it "should save settings" do
    guest = GuestUser.create! :name => 'guest', :settings => { :limit => 100, :newsletter => false }
    guest.reload
    
    guest.settings.limit.should eq(100)
    guest.settings.newsletter.should eq(false)
  end
  
  it "should not conflict with base class" do
    user = User.new :name => 'user', :settings => { :limit => 2000, :newsletter => true }
    guest = GuestUser.new :name => 'guest', :settings => { :limit => 100, :newsletter => false }
    
    user.settings.limit.should eq(2000)
    user.settings.newsletter.should eq(true)
    
    guest.settings.limit.should eq(100)
    guest.settings.newsletter.should eq(false)
  end
end