require 'enum'

module Enum::Helpers::EnumGenerator
  def enum(name, hash)
    const_set name, Enum.new(name, self, hash)
  end
end

# Every module or class shall have it
class Module
  include Enum::Helpers::EnumGenerator
end
