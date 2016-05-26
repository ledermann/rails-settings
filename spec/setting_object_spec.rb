require 'spec_helper'

describe RailsSettings::SettingObject do
  let(:user) { User.create! :name => 'Mr. Pink' }

  if RailsSettings.can_protect_attributes?
    let(:new_setting_object) { user.setting_objects.build({ :var => 'dashboard'}, :without_protection => true) }
    let(:saved_setting_object) { user.setting_objects.create!({ :var => 'dashboard', :value => { 'theme' => 'pink', 'filter' => false}}, :without_protection => true) }
  else
    let(:new_setting_object) { user.setting_objects.build({ :var => 'dashboard'}) }
    let(:saved_setting_object) { user.setting_objects.create!({ :var => 'dashboard', :value => { 'theme' => 'pink', 'filter' => false}}) }
  end

  describe "serialization" do
    it "should have a hash default" do
      expect(RailsSettings::SettingObject.new.value).to eq({})
    end
  end

  describe "Getter and Setter" do
    context "on unsaved settings" do
      it "should respond to setters" do
        expect(new_setting_object).to respond_to(:foo=)
        expect(new_setting_object).to respond_to(:bar=)
      end

      it "should not respond to some getters" do
        expect { new_setting_object.foo! }.to raise_error(NoMethodError)
        expect { new_setting_object.foo? }.to raise_error(NoMethodError)
      end

      it "should not respond if a block is given" do
        expect {
          new_setting_object.foo do
          end
        }.to raise_error(NoMethodError)
      end

      it "should not respond if params are given" do
        expect { new_setting_object.foo(42) }.to raise_error(NoMethodError)
        expect { new_setting_object.foo(42,43) }.to raise_error(NoMethodError)
      end

      it "should return nil for unknown attribute" do
        expect(new_setting_object.foo).to eq(nil)
        expect(new_setting_object.bar).to eq(nil)
      end

      it "should return defaults" do
        expect(new_setting_object.theme).to eq('blue')
        expect(new_setting_object.view).to eq('monthly')
        expect(new_setting_object.filter).to eq(true)
      end

      it "should store different objects to value hash" do
        new_setting_object.integer = 42
        new_setting_object.float   = 1.234
        new_setting_object.string  = 'Hello, World!'
        new_setting_object.array   = [ 1,2,3 ]
        new_setting_object.symbol  = :foo

        expect(new_setting_object.value).to eq('integer' => 42,
                                           'float'   => 1.234,
                                           'string'  => 'Hello, World!',
                                           'array'   => [ 1,2,3 ],
                                           'symbol'  => :foo)
      end

      it "should set and return attributes" do
        new_setting_object.theme = 'pink'
        new_setting_object.foo = 42
        new_setting_object.bar = 'hello'

        expect(new_setting_object.theme).to eq('pink')
        expect(new_setting_object.foo).to eq(42)
        expect(new_setting_object.bar).to eq('hello')
      end

      it "should set dirty trackers on change" do
        new_setting_object.theme = 'pink'
        expect(new_setting_object).to be_value_changed
        expect(new_setting_object).to be_changed
      end
    end

    context "on saved settings" do
      it "should not set dirty trackers on setting same value" do
        saved_setting_object.theme = 'pink'
        expect(saved_setting_object).not_to be_value_changed
        expect(saved_setting_object).not_to be_changed
      end

      it "should delete key on assigning nil" do
        saved_setting_object.theme = nil
        expect(saved_setting_object.value).to eq({ 'filter' => false })
      end
    end
  end

  describe "update_attributes" do
    it 'should save' do
      expect(new_setting_object.update_attributes(:foo => 42, :bar => 'string')).to be_truthy
      new_setting_object.reload

      expect(new_setting_object.foo).to eq(42)
      expect(new_setting_object.bar).to eq('string')
      expect(new_setting_object).not_to be_new_record
      expect(new_setting_object.id).not_to be_zero
    end

    it 'should not save blank hash' do
      expect(new_setting_object.update_attributes({})).to be_truthy
    end

    if RailsSettings.can_protect_attributes?
      it 'should not allow changing protected attributes' do
        new_setting_object.update_attributes!(:var => 'calendar', :foo => 42)

        expect(new_setting_object.var).to eq('dashboard')
        expect(new_setting_object.foo).to eq(42)
      end
    end
  end

  describe "save" do
    it "should save" do
      new_setting_object.foo = 42
      new_setting_object.bar = 'string'
      expect(new_setting_object.save).to be_truthy
      new_setting_object.reload

      expect(new_setting_object.foo).to eq(42)
      expect(new_setting_object.bar).to eq('string')
      expect(new_setting_object).not_to be_new_record
      expect(new_setting_object.id).not_to be_zero
    end
  end

  describe "validation" do
    it "should not validate for unknown var" do
      new_setting_object.var = "unknown-var"

      expect(new_setting_object).not_to be_valid
      expect(new_setting_object.errors[:var]).to be_present
    end
  end
end
