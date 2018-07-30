require 'spec_helper'

module RailsSettings
  class Dummy
  end

  describe Configuration, 'successful' do
    it "should define single key" do
      Configuration.new(Dummy, :dashboard)

      expect(Dummy.setting_keys[:dashboard][:default_value]).to eq({})
      expect(Dummy.setting_keys[:dashboard][:class_name]).to eq('RailsSettings::SettingObject')
    end

    it "should define multiple keys" do
      Configuration.new(Dummy, :dashboard, :calendar)

      expect(Dummy.setting_keys[:dashboard][:default_value]).to eq({})
      expect(Dummy.setting_keys[:calendar][:default_value]).to eq({})
      expect(Dummy.setting_keys[:dashboard][:class_name]).to eq('RailsSettings::SettingObject')
      expect(Dummy.setting_keys[:calendar][:class_name]).to eq('RailsSettings::SettingObject')
    end

    it "should define single key with class_name" do
      Configuration.new(Dummy, :dashboard, :class_name => 'ProjectSettingObject')
      expect(Dummy.setting_keys[:dashboard][:default_value]).to eq({})
      expect(Dummy.setting_keys[:dashboard][:class_name]).to eq('ProjectSettingObject')
    end

    it "should define multiple keys with class_name" do
      Configuration.new(Dummy, :dashboard, :calendar, :class_name => 'ProjectSettingObject')

      expect(Dummy.setting_keys[:dashboard][:default_value]).to eq({})
      expect(Dummy.setting_keys[:calendar][:default_value]).to eq({})
      expect(Dummy.setting_keys[:dashboard][:class_name]).to eq('ProjectSettingObject')
      expect(Dummy.setting_keys[:calendar][:class_name]).to eq('ProjectSettingObject')
    end

    it "should define using block" do
      Configuration.new(Dummy) do |c|
        c.key :dashboard
        c.key :calendar
      end

      expect(Dummy.setting_keys[:dashboard][:default_value]).to eq({})
      expect(Dummy.setting_keys[:calendar][:default_value]).to eq({})
      expect(Dummy.setting_keys[:dashboard][:class_name]).to eq('RailsSettings::SettingObject')
      expect(Dummy.setting_keys[:calendar][:class_name]).to eq('RailsSettings::SettingObject')
    end

    it "should define using block with defaults" do
      Configuration.new(Dummy) do |c|
        c.key :dashboard, :defaults => { :theme => 'red' }
        c.key :calendar, :defaults => { :scope => 'all' }
      end

      expect(Dummy.setting_keys[:dashboard][:default_value]).to eq({ 'theme' => 'red' })
      expect(Dummy.setting_keys[:calendar][:default_value]).to eq({ 'scope' => 'all'})
      expect(Dummy.setting_keys[:dashboard][:class_name]).to eq('RailsSettings::SettingObject')
      expect(Dummy.setting_keys[:calendar][:class_name]).to eq('RailsSettings::SettingObject')
    end

    it "should define using block and class_name" do
      Configuration.new(Dummy, :class_name => 'ProjectSettingObject') do |c|
        c.key :dashboard
        c.key :calendar
      end

      expect(Dummy.setting_keys[:dashboard][:default_value]).to eq({})
      expect(Dummy.setting_keys[:calendar][:default_value]).to eq({})
      expect(Dummy.setting_keys[:dashboard][:class_name]).to eq('ProjectSettingObject')
      expect(Dummy.setting_keys[:calendar][:class_name]).to eq('ProjectSettingObject')
    end
  end

  describe Configuration, 'failure' do
    it "should fail without args" do
      expect {
        Configuration.new
      }.to raise_error(ArgumentError)
    end

    it "should fail without keys" do
      expect {
        Configuration.new(Dummy)
      }.to raise_error(ArgumentError)
    end

    it "should fail without keys in block" do
      expect {
        Configuration.new(Dummy) do |c|
        end
      }.to raise_error(ArgumentError)
    end

    it "should fail with keys not being symbols" do
      expect {
        Configuration.new(Dummy, 42, "string")
      }.to raise_error(ArgumentError)
    end

    it "should fail with keys not being symbols" do
      expect {
        Configuration.new(Dummy) do |c|
          c.key 42, "string"
        end
      }.to raise_error(ArgumentError)
    end

    it "should fail with unknown option" do
      expect {
        Configuration.new(Dummy) do |c|
          c.key :dashboard, :foo => {}
        end
      }.to raise_error(ArgumentError)
    end

    it "should fail with an invalid settings object" do
      expect {
        Configuration.new(Dummy) do |c|
          c.key :dashboard, :class_name => "InvalidSettingObject"
        end
      }.to raise_error(ArgumentError)
    end
  end
end
