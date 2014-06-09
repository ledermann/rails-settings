require 'spec_helper'

describe 'scopes' do
  let!(:user1) { User.create! :name => 'Mr. White' do |user| user.settings(:dashboard).theme = 'white' end }
  let!(:user2) { User.create! :name => 'Mr. Blue' }

  it "should find objects with existing settings" do
    expect(User.with_settings).to eq([user1])
  end

  it "should find objects with settings for key" do
    expect(User.with_settings_for(:dashboard)).to eq([user1])
    expect(User.with_settings_for(:foo)).to eq([])
  end

  it "should records without settings" do
    expect(User.without_settings).to eq([user2])
  end

  it "should records without settings for key" do
    expect(User.without_settings_for(:foo)).to eq([user1, user2])
    expect(User.without_settings_for(:dashboard)).to eq([user2])
  end

  it "should require symbol as key" do
    [ nil, "string", 42 ].each do |invalid_key|
      expect { User.without_settings_for(invalid_key) }.to raise_error(ArgumentError)
      expect { User.with_settings_for(invalid_key)    }.to raise_error(ArgumentError)
    end
  end
end
