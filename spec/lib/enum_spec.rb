require 'spec_helper'

describe Enum do
  context "accessors" do
    before { @enum = Enum.new(:MY_COLORS, :red => 1, :blue => 2) }

    specify { @enum.red.should == 1 }
    specify { @enum[:red].should == 1 }
    specify { expect { @enum[:black] }.to raise_error(StandardError) }
    specify { @enum[:red, :blue].should == [1, 2] }
  end # context "accessors

  context "keys on left and right" do
    before { @enum = Enum.new(:MY_COLORS, :red => 1, 2 => :blue) }
    subject { @enum }

    its(:names) { should have(2).items }
    its(:names) { should include(:red, :blue) }
    its(:values) { should have(2).items }
    its(:values) { should include(1, 2) }
    its(:to_a) { should have(2).items }
  end # context "keys on left and right"

  context "no parent" do
    before { @enum = Enum.new(:MY_COLORS, :red => 1, :blue => 2) }
    subject { @enum }

    its(:to_s)    { should == "MY_COLORS" }
    its(:inspect) { should == "MY_COLORS(:red => 1, :blue => 2)" }
  end # context "no parent"

  context "with parent" do
    before { @enum = Enum.new(:MY_COLORS, Object, :red => 1, :blue => 2) }
    subject { @enum }

    its(:to_s)    { should == "Object::MY_COLORS" }
    its(:inspect) { should == "Object::MY_COLORS(:red => 1, :blue => 2)" }
  end # context "with parent"
end # describe Enum
