require 'spec_helper'

class UsesEnumColumn < Hash # to allow setting 'attributes'
  extend Enum::Helpers::EnumColumn

  class << self
    # enum definition
    def define_enum(attr, name_or_enum, options={}, hash=nil)
      @enum_name = name_or_enum.is_a?(Enum) ? name_or_enum.name : name_or_enum
      reset_mocks
      enum_column attr, name_or_enum, options, hash
    end
    def undefine_enum
      remove_const :COLORS
    end
    def reset_mocks
      @inclusion_validations = []
      @scopes = []
    end

    # mocking validates_inclusion_of
    attr_reader :inclusion_validations
    def validates_inclusion_of(*attributes)
      @inclusion_validations << attributes
    end
    # mocking scopes
    def where(*attributes)
      { :where => attributes }
    end
    attr_reader :scopes
    def scope(name, value)
      @scopes << [name, value.call]
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

class UsesAnoterEnumColumn < UsesEnumColumn
end

def enum_generator_specs
  describe Enum::Helpers::EnumGenerator do
    subject { UsesEnumColumn::COLORS }

    its(:name) { should == :COLORS }
    its(:klass) { should == UsesEnumColumn }
    its(:by_name) { should == { :red => 1, :blue => 2 } }
  end # describe Enum::Helpers::EnumGenerator
end

def enum_columns_attribute_specs
  context "attributes" do
    before do
      @record = UsesEnumColumn.new
      @record[:color] = :unknown
    end
    subject { @record }

    context "setter" do
      specify "nil" do
        @record.color = nil
        @record[:color].should be_nil
      end

      specify "name" do
        @record.color = :red
        @record[:color].should == 1
        @record[:color].should_not respond_to(:enum_value?)
      end

      specify "value" do
        @record.color = 2
        @record[:color].should == 2
        @record[:color].should_not respond_to(:enum_value?)
      end

      specify "invalid" do
        expect { @record.color = 3 }.to raise_error(StandardError)
      end
    end # context "setter"

    context "getter" do
      specify "nil" do
        @record[:color] = nil
        @record.color.should be_nil
      end

      specify "value" do
        @record[:color] = 2
        @record.color.should be_enum_value and @record.color.should be_blue
      end

      specify "invalid" do
        @record[:color] = 3
        @record.color.should_not respond_to(:enum_value?) and @record.color.should == 3
      end
    end # context "getter"
  end # context "attribute"

  context "validations" do
    its(:inclusion_validations) { should have(1).item }
    its(:inclusion_validations) { should include([:color, :in => [1, 2], :allow_nil => true]) }
  end # context "validations"
end

describe Enum::Helpers::EnumColumn do
  after { UsesEnumColumn.undefine_enum }
  subject { UsesEnumColumn }

  context "not scoped" do
    before { UsesEnumColumn.define_enum(:color, :COLORS, :red => 1, :blue => 2) }

    enum_generator_specs
    enum_columns_attribute_specs
  end # context "not scoped"

  context "scoped" do
    before { UsesEnumColumn.define_enum(:color, :COLORS, { :scoped => true }, :red => 1, :blue => 2) }

    enum_generator_specs
    enum_columns_attribute_specs

    context "scopes" do
      its(:scopes) { should have(2).items }
      its(:scopes) { should include([:red, :where => [:color => 1]]) }
      its(:scopes) { should include([:blue, :where => [:color => 2]]) }
    end # context "scopes"

    context "questions" do
      before do
        @record = UsesEnumColumn.new
        @record.color = :red
      end
      subject { @record }

      it { should be_red }
      it { should_not be_blue }
    end # context "questions"
  end # context "scoped"

  context "use another enum" do
    before do
      UsesEnumColumn.define_enum(:color, :COLORS, { :scoped => true }, :red => 1, :blue => 2)
      UsesAnoterEnumColumn.define_enum(:color, UsesEnumColumn::COLORS)
    end

    enum_generator_specs
    enum_columns_attribute_specs
  end
end # describe Enum::Helpers::EnumColumn
