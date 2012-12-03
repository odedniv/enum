module EnumGenerator
  def enum(name, hash)
    const_set name, Enum.new(name, self, hash)
  end
end

class Object
  include EnumGenerator
end

module EnumColumns
  # Bind a column to an enum by:
  #   Generating attribute reader and writer to convert to EnumValue.
  #   Creating a validation for the attribute so it must have valid enum values (allowing nil).
  #   If :scoped => true, generates scopes and questioning methods for every name in the enum.
  # If given a enum name (a symbol) and hash, also creates the enum.
  def enum_column(attr, name_or_enum, options={}, hash=nil)
    # generating or getting the enum
    if name_or_enum.is_a?(Symbol)
      # the first hash is either options or the hash if the options are missing
      hash, options = options, {} if hash.nil?
      # generating the enum if the hash is not empty
      enum name_or_enum, hash if hash.any?

      e = const_get(name_or_enum)
    else
      e = name_or_enum
    end
    # attribute reader
    define_method(attr) { v = super(); (v.nil? or e.values.exclude?(v)) ? v : e[v] }
    # attribute writer
    define_method("#{attr}=") { |v| v.nil? ? super(v) : super(e[v]) }
    # validation
    validates_inclusion_of attr, :in => e.values, :allow_nil => true
    if options[:scoped]
      # generating scopes and questioning methods
      e.by_name.each do |n, ev|
        scope n, where(attr => ev)
        define_method("#{n}?") { self[attr] == ev }
      end
    end
  end
end

if defined?(ActiveRecord)
  class ActiveRecord::Base
    extend EnumColumns
  end
end
