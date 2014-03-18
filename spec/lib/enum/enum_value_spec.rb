require 'spec_helper'

class I18n
  def self.t(path, scope: nil, default: nil)
    "#{scope}.#{path}"
  end
end

describe Enum::EnumValue do
  subject { @enum }

  context "no parent" do
    before { @enum = Enum.new(:MY_COLORS, :red => 1, :blue => 2) }
    # can't use subject @enum.red as it turns into a Fixnum

    specify { @enum.red.inspect.should == "MY_COLORS.red" }
    specify { @enum.red.t.should == "enums.my_colors.red" }
  end # context "no parent"

  context "with parent" do
    before { @enum = Enum.new(:MY_COLORS, Object, :red => 1, :blue => 2) }
    # can't use subject @enum.red as it turns into a Fixnum

    specify { @enum.red.inspect.should == "Object::MY_COLORS.red" }
    specify { @enum.red.t.should == "enums.object.my_colors.red" }
  end # context "with parent"

  context "comparison" do
    before { @enum = Enum.new(:MY_COLORS, :red => 1, :blue => 2) }

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
  end # context "comparison"

  context "invalid" do
    specify { expect { @enum[:green] }.to raise_error(StandardError) }
    specify { expect { @enum[3] }.to raise_error(StandardError) }
  end # context "invalid"
end # describe EnumValue
