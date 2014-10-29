require 'spec_helper'
require 'lib/enum/helpers/common_specs'

class EnumColumnUser < EnumUserBase
  extend Enum::Helpers::EnumColumn
  class << self
    # mocking validates_inclusion_of
    attr_reader :inclusion_validations
    def validates_inclusion_of(*attributes)
      (@inclusion_validations ||= []) << attributes
    end
    # mocking scopes
    def where(*attributes)
      { :where => attributes }
    end
    attr_reader :scopes
    def scope(name, value)
      (@scopes ||= []) << [name, value.call]
    end
  end
end

describe Enum::Helpers::EnumColumn do
  shared_examples_for "validations" do
    its(:inclusion_validations) { should have(1).item }
    its(:inclusion_validations) { should include([:color, :in => [1, 2], :allow_nil => true]) }
  end

  subject(:klass) { EnumColumnUser.create_class }

  context "not scoped" do
    before { klass.enum_column(:color, :COLORS, :red => 1, :blue => 2) }

    it_behaves_like Enum::Helpers::EnumGenerator
    it_behaves_like "validations"
  end

  context "scoped" do
    before { klass.enum_column(:color, :COLORS, { :scoped => true }, :red => 1, :blue => 2) }

    it_behaves_like Enum::Helpers::EnumGenerator
    it_behaves_like Enum::Helpers::EnumAttribute
    it_behaves_like "validations"

    describe "scopes" do
      its(:scopes) { should have(2).items }
      its(:scopes) { should include([:red, :where => [:color => 1]]) }
      its(:scopes) { should include([:blue, :where => [:color => 2]]) }
    end

    describe "questions" do
      subject(:record) { klass.new }
      before { record.color = :red }

      it { should be_red }
      it { should_not be_blue }
    end
  end

  context "use another enum" do
    subject(:klass) { EnumColumnUser.create_class }

    before do
      klass.enum_column(:color, :COLORS, { :scoped => true }, :red => 1, :blue => 2)
      another_klass = EnumColumnUser.create_class(:AnotherEnumColumnUser)
      another_klass.enum_column(:color, klass::COLORS)
    end

    it_behaves_like Enum::Helpers::EnumGenerator
    it_behaves_like Enum::Helpers::EnumAttribute
    it_behaves_like "validations"
  end
end
