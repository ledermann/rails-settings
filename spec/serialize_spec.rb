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

      expect(dashboard_settings.var).to eq('dashboard')
      expect(dashboard_settings.value).to eq({'theme' => 'white'})

      expect(calendar_settings.var).to eq('calendar')
      expect(calendar_settings.value).to eq({'scope' => 'all'})
    end
  end

  describe 'updated settings' do
    it 'should be serialized' do
      user.settings(:dashboard).update_attributes! :smart => true

      dashboard_settings = user.setting_objects.where(:var => 'dashboard').first
      calendar_settings = user.setting_objects.where(:var => 'calendar').first

      expect(dashboard_settings.var).to eq('dashboard')
      expect(dashboard_settings.value).to eq({'theme' => 'white', 'smart' => true})

      expect(calendar_settings.var).to eq('calendar')
      expect(calendar_settings.value).to eq({'scope' => 'all'})
    end
  end
end
