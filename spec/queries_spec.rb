require 'spec_helper'

describe 'Queries performed' do
  context 'New record' do
    let!(:user) { User.new :name => 'Mr. Pink' }

    it 'should be saved by one SQL query' do
      expect {
        user.save!
      }.to perform_queries(1)
    end
    
    it 'should be saved with settings for one key by two SQL queries' do
      expect {
        user.settings(:dashboard).foo = 42
        user.settings(:dashboard).bar = 'string'
        user.save!
      }.to perform_queries(2)
    end
    
    it 'should be saved with settings for two keys by three SQL queries' do
      expect {
        user.settings(:dashboard).foo = 42
        user.settings(:dashboard).bar = 'string'
        user.settings(:calendar).bar = 'string'
        user.save!
      }.to perform_queries(3)
    end
  end
  
  context 'Existing record without settings' do
    let!(:user) { User.create! :name => 'Mr. Pink' }

    it 'should be saved without SQL queries' do
      expect {
        user.save!
      }.to perform_queries(0)
    end
    
    it 'should be saved with settings for one key by two SQL queries' do
      expect {
        user.settings(:dashboard).foo = 42
        user.settings(:dashboard).bar = 'string'
        user.save!
      }.to perform_queries(2)
    end
    
    it 'should be saved with settings for two keys by three SQL queries' do
      expect {
        user.settings(:dashboard).foo = 42
        user.settings(:dashboard).bar = 'string'
        user.settings(:calendar).bar = 'string'
        user.save!
      }.to perform_queries(3)
    end
  end
  
  context 'Existing record with settings' do
    let!(:user) do
      User.create! :name => 'Mr. Pink' do |user|
        user.settings(:dashboard).theme = 'pink'
        user.settings(:calendar).scope = 'all'
      end
    end

    it 'should be saved without SQL queries' do
      expect {
        user.save!
      }.to perform_queries(0)
    end
    
    it 'should be saved with settings for one key by one SQL queries' do
      expect {
        user.settings(:dashboard).foo = 42
        user.settings(:dashboard).bar = 'string'
        user.save!
      }.to perform_queries(1)
    end
    
    it 'should be saved with settings for two keys by two SQL queries' do
      expect {
        user.settings(:dashboard).foo = 42
        user.settings(:dashboard).bar = 'string'
        user.settings(:calendar).bar = 'string'
        user.save!
      }.to perform_queries(2)
    end
    
    it 'should be destroyed by two SQL queries' do
      expect {
        user.destroy
      }.to perform_queries(2)
    end
    
    it "should update settings by one SQL query" do
      expect {
        user.settings(:dashboard).update_attributes! :foo => 'bar'
      }.to perform_queries(1)
    end
    
    it "should not touch database if there are no changes made" do
      expect {
        user.settings(:dashboard).update_attributes :theme => 'pink'
        user.settings(:calendar).update_attributes :scope => 'all'
      }.to perform_queries(0)
    end
  end
end