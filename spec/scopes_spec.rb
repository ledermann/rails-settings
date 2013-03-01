require 'spec_helper'

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
