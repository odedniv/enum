require 'enum/helpers/enum_generator'

module Enum::Helpers::EnumAttribute
  include Enum::Helpers::EnumGenerator

  # Bind an attribute to an enum by:
  #   Generating attribute reader and writer to convert to EnumValue.
  #   If :qualifier => true, generates questioning methods for every name in the enum.
  # If given a enum name (a symbol) and hash, also creates the enum.
  def attr_enum(attr, name_or_enum, options = {}, hash = nil)
    # the first hash is either options or the hash if the options are missing
    hash, options = options, {} unless name_or_enum.is_a?(Enum) or hash
    # generating or getting the enum
    if name_or_enum.is_a?(Enum)
      e = name_or_enum
    else
      # generating the enum if the hash is not empty
      enum name_or_enum, hash if hash.any?
      e = const_get(name_or_enum)
    end
    # attribute reader
    define_method(attr) do
      v = super()
      (ev = e.get(v)).nil? ? Enum::EnumValue.new(e, v) : ev
    end
    # attribute writer
    define_method("#{attr}=") do |v|
      case
      when v.enum_value?
        super(v.value)
      when v.nil?, v == "" # might be received from forms
        super(v)
      else
        super(e[v].value)
      end
    end

    if options[:qualifier]
      # generating scopes and questioning methods
      e.by_name.each do |n, ev|
        define_method("#{n}?") { send(attr) == ev }
      end
    end

    e
  end
end

# Every module or class shall have it
class Module
  include Enum::Helpers::EnumAttribute
end
