require 'spec_helper'

module RSpec
  module Mocks
    describe "a double _not_ acting as a null object" do
      before(:each) do
        @double = double('non-null object')
      end

      it "says it does not respond to messages it doesn't understand" do
        @double.should_not respond_to(:foo)
      end

      it "says it responds to messages it does understand" do
        @double.stub(:foo)
        @double.should respond_to(:foo)
      end

      it "raises an error when interpolated in a string as an integer" do
        # Not sure why, but 1.9.2 raises a different error than 1.8.7 and 1.9.3...
        expected_error = RUBY_VERSION == '1.9.2' ?
                         RSpec::Mocks::MockExpectationError :
                         TypeError

        expect { "%i" % @double }.to raise_error(expected_error)
      end
    end

    describe "a double acting as a null object" do
      before(:each) do
        @double = double('null object').as_null_object
      end

      it "says it responds to everything" do
        @double.should respond_to(:any_message_it_gets)
      end

      it "allows explicit stubs" do
        @double.stub(:foo) { "bar" }
        @double.foo.should eq("bar")
      end

      it "allows explicit expectation" do
        @double.should_receive(:something)
        @double.something
      end

      it 'continues to return self from an explicit expectation' do
        @double.should_receive(:bar)
        @double.foo.bar.should be(@double)
      end

      it "fails verification when explicit exception not met" do
        lambda do
          @double.should_receive(:something)
          @double.rspec_verify
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "ignores unexpected methods" do
        @double.random_call("a", "d", "c")
        @double.rspec_verify
      end

      it "allows expected message with different args first" do
        @double.should_receive(:message).with(:expected_arg)
        @double.message(:unexpected_arg)
        @double.message(:expected_arg)
      end

      it "allows expected message with different args second" do
        @double.should_receive(:message).with(:expected_arg)
        @double.message(:expected_arg)
        @double.message(:unexpected_arg)
      end

      it "can be interpolated in a string as an integer" do
        # This form of string interpolation calls
        # @double.to_int.to_int.to_int...etc until it gets an integer,
        # and thus gets stuck in an infinite loop unless our double
        # returns an int value from #to_int.
        ("%i" % @double).should eq("0")
      end
    end
    
    describe "#as_null_object" do
      it "sets the object to null_object" do
        obj = double('anything').as_null_object
        obj.should be_null_object
      end
    end

    describe "#null_object?" do
      it "defaults to false" do
        obj = double('anything')
        obj.should_not be_null_object
      end
    end
  end
end
