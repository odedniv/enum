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

shared_examples_for Enum::Helpers::EnumAttribute do
  subject(:record) { klass.new }
  before { record.instance_eval { @color = :unknown } }

  describe "setter" do
    context "nil" do
      before { record.color = nil }
      specify { record.instance_eval { @color }.should be_nil }
      specify { record.instance_eval { @color }.should_not be_enum_value }
    end

    context "name" do
      before { record.color = :red }
      specify { record.instance_eval { @color }.should == 1 }
      specify { record.instance_eval { @color }.should_not be_enum_value }
    end

    context "value" do
      before { record.color = 2 }
      specify { record.instance_eval { @color }.should == 2 }
      specify { record.instance_eval { @color }.should_not be_enum_value }
    end

    specify "invalid" do
      expect { @record.color = 3 }.to raise_error(StandardError)
    end
  end

  describe "getter" do
    context "nil" do
      before { record.instance_eval { @color = nil } }
      specify { record.color.should be_nil }
      specify { record.color.should be_enum_value }
    end

    context "value" do
      before { record.instance_eval { @color = 2 } }
      specify { record.color.should be_blue }
      specify { record.color.should be_enum_value }
    end

    context "invalid" do
      before { record.instance_eval { @color = 3 } }
      specify { record.color.should == 3 }
      specify { record.color.should be_enum_value }
    end
  end
end
