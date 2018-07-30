require 'spec_helper'

describe "Defaults" do
  it "should be stored for simple class" do
    expect(Account.default_settings).to eq(:portal => {})
  end

  it "should be stored for parent class" do
    expect(User.default_settings).to eq(:dashboard => { 'theme' => 'blue', 'view' => 'monthly', 'filter' => true },
                                    :calendar => { 'scope' => 'company'})
  end

  it "should be stored for child class" do
    expect(GuestUser.default_settings).to eq(:dashboard => { 'theme' => 'red', 'view' => 'monthly', 'filter' => true })
  end
end

describe "Getter/Setter" do
  let(:account) { Account.new :subdomain => 'foo' }

  it "should handle method syntax" do
    account.settings(:portal).enabled = true
    account.settings(:portal).template = 'black'

    expect(account.settings(:portal).enabled).to eq(true)
    expect(account.settings(:portal).template).to eq('black')
  end

  it "should return nil for not existing key" do
    expect(account.settings(:portal).foo).to eq(nil)
  end
end

describe 'Objects' do
  context 'without defaults' do
    let(:account) { Account.new :subdomain => 'foo' }

    it 'should have blank settings' do
      expect(account.settings(:portal).value).to eq({})
    end

    it 'should allow saving a blank value' do
      account.save!
      expect(account.settings(:portal).save).to be_truthy
    end

    it 'should allow removing all values' do
      account.settings(:portal).premium = true
      account.settings(:portal).fee = 42.5
      account.save!

      account.settings(:portal).premium = nil
      expect(account.save).to be_truthy

      account.settings(:portal).fee = nil
      expect(account.save).to be_truthy
    end

    it 'should not add settings on saving' do
      account.save!
      expect(RailsSettings::SettingObject.count).to eq(0)
    end

    it "should save object with settings" do
      account.settings(:portal).premium = true
      account.settings(:portal).fee = 42.5
      account.save!

      account.reload
      expect(account.settings(:portal).premium).to eq(true)
      expect(account.settings(:portal).fee).to eq(42.5)

      expect(RailsSettings::SettingObject.count).to eq(1)
      expect(RailsSettings::SettingObject.first.value).to eq({ 'premium' => true, 'fee' => 42.5 })
    end

    it "should save settings separated" do
      account.save!

      settings = account.settings(:portal)
      settings.enabled = true
      settings.template = 'black'
      settings.save!

      account.reload
      expect(account.settings(:portal).enabled).to eq(true)
      expect(account.settings(:portal).template).to eq('black')
    end
  end

  context 'with defaults' do
    let(:user) { User.new :name => 'Mr. Brown' }

    it 'should have default settings' do
      expect(user.settings(:dashboard).theme).to eq('blue')
      expect(user.settings(:dashboard).view).to eq('monthly')
      expect(user.settings(:dashboard).filter).to eq(true)
      expect(user.settings(:calendar).scope).to eq('company')
    end

    it 'should have default settings after changing one' do
      user.settings(:dashboard).theme = 'gray'

      expect(user.settings(:dashboard).theme).to eq('gray')
      expect(user.settings(:dashboard).view).to eq('monthly')
      expect(user.settings(:dashboard).filter).to eq(true)
      expect(user.settings(:calendar).scope).to eq('company')
    end

    it "should overwrite settings" do
      user.settings(:dashboard).theme = 'brown'
      user.settings(:dashboard).filter = false
      user.save!

      user.reload
      expect(user.settings(:dashboard).theme).to eq('brown')
      expect(user.settings(:dashboard).filter).to eq(false)
      expect(RailsSettings::SettingObject.count).to eq(1)
      expect(RailsSettings::SettingObject.first.value).to eq({ 'theme' => 'brown', 'filter' => false })
    end

    it "should merge settings with defaults" do
      user.settings(:dashboard).theme = 'brown'
      user.save!

      user.reload
      expect(user.settings(:dashboard).theme).to eq('brown')
      expect(user.settings(:dashboard).filter).to eq(true)
      expect(RailsSettings::SettingObject.count).to eq(1)
      expect(RailsSettings::SettingObject.first.value).to eq({ 'theme' => 'brown' })
    end
  end
end

describe "Object without settings" do
  let!(:user) { User.create! :name => 'Mr. White' }

  it "should respond to #settings?" do
    expect(user.settings?).to eq(false)
    expect(user.settings?(:dashboard)).to eq(false)
  end

  it "should have no setting objects" do
    expect(RailsSettings::SettingObject.count).to eq(0)
  end

  it "should add settings" do
    user.settings(:dashboard).update_attributes! :smart => true

    user.reload
    expect(user.settings(:dashboard).smart).to eq(true)
  end

  it "should not save settings if assigned nil" do
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

  it "should respond to #settings?" do
    expect(user.settings?).to eq(true)

    expect(user.settings?(:dashboard)).to eq(true)
    expect(user.settings?(:calendar)).to eq(true)
  end

  it "should have two setting objects" do
    expect(RailsSettings::SettingObject.count).to eq(2)
  end

  it "should update settings" do
    user.settings(:dashboard).update_attributes! :smart => true
    user.reload

    expect(user.settings(:dashboard).smart).to eq(true)
    expect(user.settings(:dashboard).theme).to eq('white')
    expect(user.settings(:calendar).scope).to eq('all')
  end

  it "should update settings by saving object" do
    user.settings(:dashboard).smart = true
    user.save!

    user.reload
    expect(user.settings(:dashboard).smart).to eq(true)
  end

  it "should destroy settings with nil" do
    expect {
      user.settings = nil
      user.save!
    }.to change(RailsSettings::SettingObject, :count).by(-2)

    expect(user.settings?).to eq(false)
  end

  it "should raise exception on assigning other than nil" do
    expect {
      user.settings = :foo
      user.save!
    }.to raise_error(ArgumentError)
  end
end

describe "Customized SettingObject" do
  let(:project) { Project.create! :name => 'Heist' }

  it "should not accept invalid attributes" do
    project.settings(:info).owner_name = 42
    expect(project.settings(:info)).not_to be_valid

    project.settings(:info).owner_name = ''
    expect(project.settings(:info)).not_to be_valid
  end

  it "should accept valid attributes" do
    project.settings(:info).owner_name = 'Mr. Brown'
    expect(project.settings(:info)).to be_valid
  end
end

describe "to_settings_hash" do
  let(:user) do
    User.new :name => 'Mrs. Fin' do |user|
      user.settings(:dashboard).theme = 'green'
      user.settings(:dashboard).sound = 11
      user.settings(:calendar).scope = 'some'
    end
  end

  it "should return defaults" do
    expect(User.new.to_settings_hash).to eq({:dashboard=>{"theme"=>"blue", "view"=>"monthly", "filter"=>true}, :calendar=>{"scope"=>"company"}})
  end

  it "should return merged settings" do
    expect(user.to_settings_hash).to eq({:dashboard=>{"theme"=>"green", "view"=>"monthly", "filter"=>true, "sound" => 11}, :calendar=>{"scope"=>"some"}})
  end
end
