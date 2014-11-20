describe Enum::Helpers::EnumGenerator do
  let(:klass) { EnumUserBase.create_class }
  before { klass.enum(:COLORS, :red => 1, :blue => 2) }
  subject { klass::COLORS }

  its(:name) { should == :COLORS }
  its(:klass) { should == klass }
  its(:by_name) { should == { :red => 1, :blue => 2 } }
end
