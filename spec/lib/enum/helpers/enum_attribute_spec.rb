require 'spec_helper'
require 'lib/enum/helpers/common_specs'

class EnumAttributeUser < EnumUserBase
  extend Enum::Helpers::EnumAttribute
end

describe Enum::Helpers::EnumAttribute do
  subject(:klass) { EnumAttributeUser.create_class }

  context "not qualifier" do
    before { klass.attr_enum(:color, :COLORS, :red => 1, :blue => 2) }

    it_behaves_like Enum::Helpers::EnumGenerator
    it_behaves_like Enum::Helpers::EnumAttribute
  end

  context "qualifier" do
    before { klass.attr_enum(:color, :COLORS, { :qualifier => true }, :red => 1, :blue => 2) }

    it_behaves_like Enum::Helpers::EnumGenerator
    it_behaves_like Enum::Helpers::EnumAttribute

    context "questions" do
      subject(:record) { klass.new }
      before { record.color = :red }

      it { should be_red }
      it { should_not be_blue }
    end
  end

  context "use another enum" do
    before do
      klass.attr_enum(:color, :COLORS, { :qualifier => true }, :red => 1, :blue => 2)
      another_klass = EnumAttributeUser.create_class(:AnotherEnumAttributeUser)
      another_klass.attr_enum(:color, klass::COLORS)
    end

    it_behaves_like Enum::Helpers::EnumGenerator
    it_behaves_like Enum::Helpers::EnumAttribute
  end
end
