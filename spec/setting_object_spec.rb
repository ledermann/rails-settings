require 'spec_helper'

describe RailsSettings::SettingObject do
  let(:user) { User.create! :name => 'Mr. Pink' }
  let(:new_setting_object) { user.setting_objects.build({ :var => 'dashboard'}, :without_protection => true) }
  let(:saved_setting_object) { user.setting_objects.create!({ :var => 'dashboard', :value => { 'theme' => 'pink', 'filter' => true}}, :without_protection => true) }

  describe "Getter and Setter" do
    context "on unsaved settings" do
      it "should respond to setters" do
        new_setting_object.should respond_to(:foo=)
        new_setting_object.should respond_to(:bar=)
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
        new_setting_object.foo.should eq(nil)
        new_setting_object.bar.should eq(nil)
      end

      it "should return defaults" do
        new_setting_object.theme.should eq('blue')
        new_setting_object.view.should eq('monthly')
        new_setting_object.filter.should eq(false)
      end

      it "should store different objects to value hash" do
        new_setting_object.integer = 42
        new_setting_object.float   = 1.234
        new_setting_object.string  = 'Hello, World!'
        new_setting_object.array   = [ 1,2,3 ]
        new_setting_object.symbol  = :foo

        new_setting_object.value.should eq('integer' => 42,
                                           'float'   => 1.234,
                                           'string'  => 'Hello, World!',
                                           'array'   => [ 1,2,3 ],
                                           'symbol'  => :foo)
      end

      it "should set and return attributes" do
        new_setting_object.theme = 'pink'
        new_setting_object.foo = 42
        new_setting_object.bar = 'hello'

        new_setting_object.theme.should eq('pink')
        new_setting_object.foo.should eq(42)
        new_setting_object.bar.should eq('hello')
      end

      it "should set dirty trackers on change" do
        new_setting_object.theme = 'pink'
        new_setting_object.should be_value_changed
        new_setting_object.should be_changed
      end
    end

    context "on saved settings" do
      it "should not set dirty trackers on setting same value" do
        saved_setting_object.theme = 'pink'
        saved_setting_object.should_not be_value_changed
        saved_setting_object.should_not be_changed
      end

      it "should delete key on assigning nil" do
        saved_setting_object.theme = nil
        saved_setting_object.value.should == { 'filter' => true }
      end
    end
  end

  describe "update_attributes" do
    it 'should save' do
      new_setting_object.update_attributes(:foo => 42, :bar => 'string').should be_true
      new_setting_object.reload

      new_setting_object.foo.should eq(42)
      new_setting_object.bar.should eq('string')
      new_setting_object.should_not be_new_record
      new_setting_object.id.should_not be_zero
    end

    it 'should not save blank hash' do
      new_setting_object.update_attributes({}).should be_false
    end

    it 'should not allow changing protected attributes' do
      new_setting_object.update_attributes!(:var => 'calendar', :foo => 42)

      new_setting_object.var.should eq('dashboard')
      new_setting_object.foo.should eq(42)
    end
  end

  describe "save" do
    it "should save" do
      new_setting_object.foo = 42
      new_setting_object.bar = 'string'
      new_setting_object.save.should be_true
      new_setting_object.reload

      new_setting_object.foo.should eq(42)
      new_setting_object.bar.should eq('string')
      new_setting_object.should_not be_new_record
      new_setting_object.id.should_not be_zero
    end
  end

  describe "validation" do
    it "should not validate for unknown var" do
      new_setting_object.var = "unknown-var"

      new_setting_object.should_not be_valid
      new_setting_object.errors[:var].should be_present
    end
  end
end
