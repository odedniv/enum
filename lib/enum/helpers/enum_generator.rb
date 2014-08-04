require 'enum'

module Enum::Helpers::EnumGenerator
  def yinum(name, hash)
    const_set name, Enum.new(name, self, hash)
  end
  alias_method :enum, :yinum
end

# Every module or class shall have it
class Module
  include Enum::Helpers::EnumGenerator
end
