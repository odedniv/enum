require 'spec_helper'

describe Enum do
  context "keys on left and right" do
    before { @enum = Enum.new(:MY_COLORS, :red => 1, 2 => :blue) }
    subject { @enum }

    its(:names) { should have(2).items }
    its(:names) { should include(:red, :blue) }
    its(:values) { should have(2).items }
    its(:values) { should include(1, 2) }
  end # context "keys on left and right"
  
  context "no parent" do
    before { @enum = Enum.new(:MY_COLORS, :red => 1, :blue => 2) }
    subject { @enum  }

    its(:to_s)    { should == "MY_COLORS" }
    its(:inspect) { should == "MY_COLORS(:red => 1, :blue => 2)" }

    context "enum value" do
      specify { @enum.red.inspect.should == "MY_COLORS.red" }
      specify { @enum.red.t.should == "I18n not available: enums.my_colors.red" }
    end # context "enum value"
  end # context "no parent"

  context "with parent" do
    before { @enum = Enum.new(:MY_COLORS, Object, :red => 1, :blue => 2) }
    subject { @enum }

    its(:to_s)    { should == "Object::MY_COLORS" }
    its(:inspect) { should == "Object::MY_COLORS(:red => 1, :blue => 2)" }

    context "enum value" do
      specify { @enum.red.inspect.should == "Object::MY_COLORS.red" }
      specify { @enum.red.t.should == "I18n not available: enums.object.my_colors.red" }
    end # context "enum value"
  end # context "with parent"

  context "enum value" do
    before { @enum = Enum.new(:MY_COLORS, :red => 1, :blue => 2) }
    subject { @enum }

    its(:red) { should == 1 }
    its(:blue) { should_not == 1 }
    its(:red) { should == :red }
    its(:blue) { should_not == :red }
    its(:red) { should === 1 }
    its(:blue) { should_not === 1 }
    its(:red) { should === :red }
    its(:blue) { should_not === :red }
    its(:red) { should be_red }
    its(:blue) { should_not be_red }
    specify { @enum.red.object_id.should == @enum[:red].object_id }
    specify { @enum.red.object_id.should == @enum[1].object_id }
  end # context "enum value"
end # describe Enum
