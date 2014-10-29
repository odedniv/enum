require 'spec_helper'

describe Enum do
  describe "accessors" do
    subject(:enum) { Enum.new(:MY_COLORS, :red => 1, :blue => 2) }

    its(:red) { should == 1 }
    specify { enum[:red].should == 1 }
    specify { expect { enum[:black] }.to raise_error(StandardError) }
    specify { enum[:red, :blue].should == [1, 2] }
  end

  context "keys on left and right" do
    subject(:enum) { Enum.new(:MY_COLORS, :red => 1, 2 => :blue) }

    its(:names) { should have(2).items }
    its(:names) { should include(:red, :blue) }
    its(:values) { should have(2).items }
    its(:values) { should include(1, 2) }
    its(:to_a) { should have(2).items }
  end

  context "no parent" do
    subject(:enum) { Enum.new(:MY_COLORS, :red => 1, :blue => 2) }

    its(:to_s)    { should == "MY_COLORS" }
    its(:inspect) { should == "MY_COLORS(:red => 1, :blue => 2)" }
  end

  context "with parent" do
    subject(:enum) { Enum.new(:MY_COLORS, Object, :red => 1, :blue => 2) }

    its(:to_s)    { should == "Object::MY_COLORS" }
    its(:inspect) { should == "Object::MY_COLORS(:red => 1, :blue => 2)" }
  end
end
