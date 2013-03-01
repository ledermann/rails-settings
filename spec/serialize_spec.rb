require 'spec_helper'

describe "Serialization" do
  let!(:user) do
    User.create! :name => 'Mr. White' do |user|
      user.settings(:dashboard).theme = 'white'
      user.settings(:calendar).scope = 'all'
    end
  end

  describe 'created settings' do
    it 'should be serialized' do
      user.reload

      dashboard_settings = user.setting_objects.where(:var => 'dashboard').first
      calendar_settings = user.setting_objects.where(:var => 'calendar').first

      dashboard_settings.var.should == 'dashboard'
      dashboard_settings.value.should eq(:theme => 'white', :view => 'monthly', :filter => false)

      calendar_settings.var.should == 'calendar'
      calendar_settings.value.should eq(:scope => 'all')
    end
  end
  
  describe 'updated settings' do
    it 'should be serialized' do
      user.update_settings! :dashboard, :smart => true

      dashboard_settings = user.setting_objects.where(:var => 'dashboard').first
      calendar_settings = user.setting_objects.where(:var => 'calendar').first

      dashboard_settings.var.should == 'dashboard'
      dashboard_settings.value.should eq(:theme => 'white', :view => 'monthly', :filter => false, :smart => true)

      calendar_settings.var.should == 'calendar'
      calendar_settings.value.should eq(:scope => 'all')
    end
  end
end
