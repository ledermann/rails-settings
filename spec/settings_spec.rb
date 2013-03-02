require 'spec_helper'

describe "Defaults" do
  it "should be stored for simple class" do
    Account.default_settings.should eq(:portal => {}.with_indifferent_access)
  end

  it "should be stored for parent class" do
    User.default_settings.should eq(:dashboard => { :theme => 'blue', :view => 'monthly', :filter => false }.with_indifferent_access, 
                                    :calendar => { :scope => 'company'}.with_indifferent_access)
  end
  
  it "should be stored for child class" do
    GuestUser.default_settings.should eq(:dashboard => { :theme => 'red', :view => 'monthly', :filter => false }.with_indifferent_access)
  end
end

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
      account.settings(:portal).value.should eq({})
    end

    it 'should not add settings on saving' do
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
      RailsSettings::SettingObject.first.value.should == { :premium => true, :fee => 42.5 }.with_indifferent_access
    end
    
    it "should save settings separated" do
      account.save!
      
      settings = account.settings(:portal)
      settings.enabled = true
      settings.template = 'black'
      settings.save!

      account.reload
      account.settings(:portal).enabled.should eq(true)
      account.settings(:portal).template.should eq('black')
    end
  end

  context 'with defaults' do
    let(:user) { User.new :name => 'Mr. Brown' }

    it 'should have default settings' do
      user.settings(:dashboard).theme.should eq('blue')
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
      RailsSettings::SettingObject.first.value.should == { :theme => 'brown', :filter => true }.with_indifferent_access
    end

    it "should merge settings with defaults" do
      user.settings(:dashboard).theme = 'brown'
      user.save!

      user.reload
      user.settings(:dashboard).theme.should eq('brown')
      user.settings(:dashboard).filter.should eq(false)
      RailsSettings::SettingObject.count.should eq(1)
      RailsSettings::SettingObject.first.value.should == { :theme => 'brown' }.with_indifferent_access
    end
  end
end

describe "Object without settings" do
  let!(:user) { User.create! :name => 'Mr. White' }
  
  it "should have no setting objects" do
    RailsSettings::SettingObject.count.should eq(0)
  end

  it "should update settings" do
    user.settings(:dashboard).update! :smart => true

    user.reload
    user.settings(:dashboard).smart.should eq(true)
  end

  it "should destroy settings with nil" do
    expect {
      user.settings = nil
      user.save!
    }.to_not change(RailsSettings::SettingObject, :count)
  end
end

describe "Object with settings" do
  let!(:user) do
    User.create! :name => 'Mr. White' do |user|
      user.settings(:dashboard).theme = 'white'
      user.settings(:calendar).scope = 'all'
    end
  end
  
  it "should have two setting objects" do
    RailsSettings::SettingObject.count.should eq(2)
  end

  it "should update settings" do
    user.settings(:dashboard).update! :smart => true
    user.reload

    user.settings(:dashboard).smart.should eq(true)
    user.settings(:dashboard).theme.should eq('white')
    user.settings(:calendar).scope.should eq('all')
  end

  it "should update settings by saving object" do
    user.settings(:dashboard).smart = true
    user.save!
    
    user.reload
    user.settings(:dashboard).smart.should eq(true)
  end
  
  it "should not update settings for unchanged attributes" do
    RailsSettings::SettingObject.any_instance.should_not_receive(:save!)
    user.settings(:dashboard).update! :theme => 'white'
  end

  it "should not update settings for blank Hash" do
    RailsSettings::SettingObject.any_instance.should_not_receive(:save!)
    user.settings(:dashboard).update!({})
  end
  
  it "should destroy settings with nil" do
    expect {
      user.settings = nil
      user.save!
    }.to change(RailsSettings::SettingObject, :count).by(-2)
  end
end

