require 'spec_helper'

class UsesEnumAttribute < Hash # to allow setting 'attributes'
  extend Enum::Helpers::EnumAttribute

  class << self
    # enum definition
    def define_enum(attr, name_or_enum, options = {}, hash = nil)
      @enum_name = name_or_enum.is_a?(Enum) ? name_or_enum.name : name_or_enum
      attr_enum attr, name_or_enum, options, hash
    end
    def undefine_enum
      remove_const :COLORS
    end
  end

  # mocking setters
  def method_missing(method, *args, &block)
    if method.to_s.end_with?('=') and args.length == 1
      self[method.to_s.chop.to_sym] = args.first
    elsif method =~ /^[a-z_]*$/ and args.length == 0
      self[method]
    else
      super
    end
  end
end

class UsesAnoterEnumAttribute < UsesEnumAttribute
end

def enum_generator_specs
  describe Enum::Helpers::EnumGenerator do
    subject { UsesEnumAttribute::COLORS }

    its(:name) { should == :COLORS }
    its(:klass) { should == UsesEnumAttribute }
    its(:by_name) { should == { :red => 1, :blue => 2 } }
  end # describe Enum::Helpers::EnumGenerator
end

def enum_attribute_specs
  context "attributes" do
    before do
      @record = UsesEnumAttribute.new
      @record[:color] = :unknown
    end
    subject { @record }

    context "setter" do
      specify "nil" do
        @record.color = nil
        @record[:color].should be_nil
        @record[:color].should_not be_enum_value
      end

      specify "name" do
        @record.color = :red
        @record[:color].should == 1
        @record[:color].should_not be_enum_value
      end

      specify "value" do
        @record.color = 2
        @record[:color].should == 2
        @record[:color].should_not be_enum_value
      end

      specify "invalid" do
        expect { @record.color = 3 }.to raise_error(StandardError)
      end
    end # context "setter"

    context "getter" do
      specify "nil" do
        @record[:color] = nil
        @record.color.should be_nil
        @record.color.should be_enum_value
      end

      specify "value" do
        @record[:color] = 2
        @record.color.should be_blue
        @record.color.should be_enum_value
      end

      specify "invalid" do
        @record[:color] = 3
        @record.color.should == 3
        @record.color.should be_enum_value
      end
    end # context "getter"
  end # context "attribute"
end

describe Enum::Helpers::EnumAttribute do
  after { UsesEnumAttribute.undefine_enum }
  subject { UsesEnumAttribute }

  context "not qualifier" do
    before { UsesEnumAttribute.define_enum(:color, :COLORS, :red => 1, :blue => 2) }

    enum_generator_specs
    enum_attribute_specs
  end # context "not qualifier"

  context "qualifier" do
    before { UsesEnumAttribute.define_enum(:color, :COLORS, { :qualifier => true }, :red => 1, :blue => 2) }

    enum_generator_specs
    enum_attribute_specs

    context "questions" do
      before do
        @record = UsesEnumAttribute.new
        @record.color = :red
      end
      subject { @record }

      it { should be_red }
      it { should_not be_blue }
    end # context "questions"
  end # context "qualifier"

  context "use another enum" do
    before do
      UsesEnumAttribute.define_enum(:color, :COLORS, { :qualifier => true }, :red => 1, :blue => 2)
      UsesAnoterEnumAttribute.define_enum(:color, UsesEnumAttribute::COLORS)
    end

    enum_generator_specs
    enum_attribute_specs
  end
end # describe Enum::Helpers::EnumAttribute
