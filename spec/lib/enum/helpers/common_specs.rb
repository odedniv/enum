class EnumUserBase
  attr_accessor :color

  class << self
    def create_class(name = self.name)
      klass_name = :"Anonymous#{name}"
      send(:remove_const, klass_name) if const_defined?(klass_name)
      const_set(klass_name, Class.new(self)) # gives a name
    end
  end
end

shared_examples_for Enum::Helpers::EnumGenerator do
  subject { klass::COLORS }

  its(:name) { should == :COLORS }
  its(:klass) { should == klass }
  its(:by_name) { should == { :red => 1, :blue => 2 } }
end

shared_examples_for Enum::Helpers::EnumAttribute do |attribute = :color|
  subject(:record) { klass.new }
  before { record.instance_variable_set("@#{attribute}", :unknown) }

  describe "setter" do
    context "nil" do
      before { record.send(:"#{attribute}=", nil) }
      specify { record.instance_variable_get("@#{attribute}").should be_nil }
      specify { record.instance_variable_get("@#{attribute}").should_not be_enum_value }
    end

    context "name" do
      before { record.send(:"#{attribute}=", :red) }
      specify { record.instance_variable_get("@#{attribute}").should == 1 }
      specify { record.instance_variable_get("@#{attribute}").should_not be_enum_value }
    end

    context "value" do
      before { record.send(:"#{attribute}=", 2) }
      specify { record.instance_variable_get("@#{attribute}").should == 2 }
      specify { record.instance_variable_get("@#{attribute}").should_not be_enum_value }
    end

    specify "invalid" do
      expect { record.send(:"#{attribute}=", 3) }.to raise_error(StandardError, /does not know/)
    end
  end

  describe "getter" do
    context "nil" do
      before { record.instance_variable_set("@#{attribute}", nil) }
      specify { record.send(attribute).should be_nil }
      specify { record.send(attribute).should be_enum_value }
    end

    context "value" do
      before { record.instance_variable_set("@#{attribute}", 2) }
      specify { record.send(attribute).should be_blue }
      specify { record.send(attribute).should be_enum_value }
    end

    context "invalid" do
      before { record.instance_variable_set("@#{attribute}", 3) }
      specify { record.send(attribute).should == 3 }
      specify { record.send(attribute).should be_enum_value }
    end
  end
end
