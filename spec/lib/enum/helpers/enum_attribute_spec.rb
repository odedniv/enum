require 'lib/enum/helpers/common_specs'

class EnumAttributeUser < EnumUserBase
  extend Enum::Helpers::EnumAttribute

  def method_missing(method_name, *attributes, &block)
    case method_name
      when :color2  then @color2
      when :color2= then @color2 = attributes.first
      else super
    end
  end
end

describe Enum::Helpers::EnumAttribute do
  subject(:klass) { EnumAttributeUser.create_class }

  shared_examples_for "attr_enum" do |attribute|
    context "not qualifier" do
      before { klass.attr_enum(attribute, :COLORS, :red => 1, :blue => 2) }

      it_behaves_like Enum::Helpers::EnumGenerator
      it_behaves_like Enum::Helpers::EnumAttribute, attribute
    end

    context "qualifier" do
      before { klass.attr_enum(attribute, :COLORS, { :qualifier => true }, :red => 1, :blue => 2) }

      it_behaves_like Enum::Helpers::EnumGenerator
      it_behaves_like Enum::Helpers::EnumAttribute, attribute

      context "questions" do
        subject(:record) { klass.new }
        before { record.send(:"#{attribute}=", :red) }

        it { should be_red }
        it { should_not be_blue }
      end
    end

    context "use another enum" do
      before do
        klass.attr_enum(attribute, :COLORS, { :qualifier => true }, :red => 1, :blue => 2)
        another_klass = EnumAttributeUser.create_class(:AnotherEnumAttributeUser)
        another_klass.attr_enum(attribute, klass::COLORS)
      end

      it_behaves_like Enum::Helpers::EnumGenerator
      it_behaves_like Enum::Helpers::EnumAttribute, attribute
    end
  end

  it_behaves_like "attr_enum", :color
  it_behaves_like "attr_enum", :color2
end
