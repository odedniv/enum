require 'spec_helper'

class UsesEnumGenerator
  enum :COLORS, :red => 1, :blue => 2
end

describe Enum::Helpers::EnumGenerator do
  subject { UsesEnumGenerator::COLORS }

  its(:name) { should == :COLORS }
  its(:klass) { should == UsesEnumGenerator }
  its(:by_name) { should == { :red => 1, :blue => 2 } }
end # describe Enum::Helpers::EnumGenerator
