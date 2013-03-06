require 'enum/helpers/enum_attribute'

module Enum::Helpers::EnumColumn
  include Enum::Helpers::EnumAttribute

  # Bind a column to an enum by:
  #   Generating attribute reader and writer to convert to EnumValue.
  #   Creating a validation for the attribute so it must have valid enum values (allowing nil).
  #   If :scoped => true, generates scopes and questioning methods for every name in the enum.
  # If given a enum name (a symbol) and hash, also creates the enum.
  def enum_column(attr, name_or_enum, options = {}, hash = nil)
    # the first hash is either options or the hash if the options are missing
    hash, options = options, {} unless name_or_enum.is_a?(Enum) or hash
    # generating the enum attribute
    e = attr_enum(attr, name_or_enum, options.merge(:qualifier => options[:scoped]), hash)
    # validation
    validates_inclusion_of attr, :in => e.values, :allow_nil => true
    if options[:scoped]
      # generating scopes and questioning methods
      e.by_name.each do |n, ev|
        scope n, where(attr => ev)
        define_method("#{n}?") { self[attr] == ev }
      end
    end

    e
  end
end

if defined?(ActiveRecord)
  class ActiveRecord::Base
    extend Enum::Helpers::EnumColumn
  end
end
