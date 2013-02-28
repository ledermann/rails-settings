require 'spec_helper'
setup_db

describe "Getter/Setter" do
  let(:account) { Account.new :subdomain => 'foo' }

  it "should handle method syntax" do
    account.settings(:portal).enabled = true
    account.settings(:portal).template = 'black'

    account.settings(:portal).enabled.should eq(true)
    account.settings(:portal).template.should eq('black')
  end
  
  it "should return nil for not existing key" do
    account.settings(:portal).foo.should eq(nil)
  end
end

describe 'Objects' do
  context 'without defaults' do
    let(:account) { Account.new :subdomain => 'foo' }

    it 'should have blank settings' do
      account.settings(:portal).should eq(OpenStruct.new)
    end

    it 'should not add settings' do
      account.save!
      RailsSettings::SettingObject.count.should eq(0)
    end

    it "should save object with settings" do
      account.settings(:portal).premium = true
      account.settings(:portal).fee = 42.5
      account.save!

      account.reload
      account.settings(:portal).premium.should eq(true)
      account.settings(:portal).fee.should eq(42.5)
      
      RailsSettings::SettingObject.count.should eq(1)
      RailsSettings::SettingObject.first.value.should == { :premium => true, :fee => 42.5 }
    end
  end

  context 'with defaults' do
    let(:user) { User.new :name => 'Mr. Brown' }

    it "should return class defaults" do
      User.default_settings.should eq({:dashboard=>{:theme=>"red", :view=>"monthly", :filter=>false}, :calendar=>{:scope=>"company"}})
    end

    it 'should have default settings' do
      user.settings(:dashboard).theme.should eq('red')
      user.settings(:dashboard).view.should eq('monthly')
      user.settings(:dashboard).filter.should eq(false)
      user.settings(:calendar).scope.should eq('company')
    end
    
    it 'should have default settings after changing one' do
      user.settings(:dashboard).theme = 'gray'
      
      user.settings(:dashboard).theme.should eq('gray')
      user.settings(:dashboard).view.should eq('monthly')
      user.settings(:dashboard).filter.should eq(false)
      user.settings(:calendar).scope.should eq('company')
    end

    it "should overwrite settings" do
      user.settings(:dashboard).theme = 'brown'
      user.settings(:dashboard).filter = true
      user.save!

      user.reload
      user.settings(:dashboard).theme.should eq('brown')
      user.settings(:dashboard).filter.should eq(true)

      RailsSettings::SettingObject.count.should eq(1)
      RailsSettings::SettingObject.first.value.should == { :theme => 'brown', :view => 'monthly', :filter => true }
    end

    it "should merge settings with defaults" do
      user.settings(:dashboard).theme = 'brown'
      user.save!

      user.reload
      user.settings(:dashboard).theme.should eq('brown')
      user.settings(:dashboard).filter.should eq(false)

      RailsSettings::SettingObject.count.should eq(1)
      RailsSettings::SettingObject.first.value.should == { :theme => 'brown', :view => 'monthly', :filter => false }
    end
  end
end

describe "Object with settings" do
  let!(:user) do
    User.create! :name => 'Mr. White' do |user|
      user.settings(:dashboard).theme = 'white'
      user.settings(:calendar).scope = 'all'
    end
  end
  
  it "should have two setting object" do
    RailsSettings::SettingObject.count.should eq(2)
  end

  it "should destroy settings with nil" do
    user.settings = nil
    user.save!
    
    RailsSettings::SettingObject.count.should eq(0)
  end
end

describe 'scopes' do
  let!(:user1) { User.create! :name => 'Mr. White' do |user| user.settings(:dashboard).theme = 'white' end }
  let!(:user2) { User.create! :name => 'Mr. Blue' }
  
  it "should find objects with existing settings" do
    User.with_settings.should eq([user1])
  end

  it "should find objects with settings for key" do
    User.with_settings_for(:dashboard).should eq([user1])
    User.with_settings_for(:foo).should eq([])
  end

  it "should records without settings" do
    User.without_settings.should eq([user2])
  end

  it "should records without settings for key" do
    User.without_settings_for(:foo).should eq([user1, user2])
    User.without_settings_for(:dashboard).should eq([user2])
  end
  
  it "should require symbol as key" do
    [ nil, "string", 42 ].each do |invalid_key|
      expect { User.without_settings_for(invalid_key) }.to raise_error(ArgumentError)
      expect { User.with_settings_for(invalid_key)    }.to raise_error(ArgumentError)
    end
  end
end

describe "Subclass" do
  it "should save settings" do
    guest = GuestUser.new :name => 'guest'
    guest.settings(:dashboard).theme = 'blue'
    guest.settings(:dashboard).filter = true
    guest.save!
    guest.reload
    
    guest.settings(:dashboard).theme.should eq('blue')
    guest.settings(:dashboard).filter.should eq(true)
  end
  
  it "should not conflict with base class" do
    user = User.new :name => 'user'
    user.settings(:dashboard).theme = 'blue'
    
    guest = GuestUser.new :name => 'guest'
    guest.settings(:dashboard).theme = 'brown'
    
    user.settings(:dashboard).theme.should eq('blue')
    user.settings(:dashboard).filter.should eq(false)
    
    guest.settings(:dashboard).theme.should eq('brown')
    guest.settings(:dashboard).filter.should eq(false)
  end
end