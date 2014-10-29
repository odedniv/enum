require 'enum/helpers/enum_generator'

module Enum::Helpers::EnumAttribute
  include Enum::Helpers::EnumGenerator

  # Bind an attribute to an enum by:
  #   Generating attribute reader and writer to convert to EnumValue.
  #   If :qualifier => true, generates questioning methods for every name in the enum.
  # If given a enum name (a symbol) and hash, also creates the enum.
  def attr_yinum(attr, name_or_enum, options = {}, hash = nil)
    # the first hash is either options or the hash if the options are missing
    hash, options = options, {} unless name_or_enum.is_a?(Enum) or hash
    # generating or getting the enum
    if name_or_enum.is_a?(Enum)
      e = name_or_enum
    else
      # generating the enum if the hash is not empty
      yinum name_or_enum, hash if hash.any?
      e = const_get(name_or_enum)
    end
    # attribute reader
    reader, reader_without_enum = attr, :"#{attr}_without_enum"
    begin
      alias_method reader_without_enum, reader
    rescue NameError # reader does not exist
    else
      define_method(reader) do
        v = send(reader_without_enum)
        (ev = e.get(v)).nil? ? Enum::EnumValue.new(e, v) : ev
      end
    end
    # attribute writer
    writer, writer_without_enum = :"#{attr}=", :"#{attr}_without_enum="
    begin
      alias_method writer_without_enum, writer
    rescue NameError # writer does not exist
    else
      define_method(writer) do |v|
        case
        when v.enum_value?
          send(writer_without_enum, v.value)
        when v.nil?, v == "" # might be received from forms
          send(writer_without_enum, v)
        else
          send(writer_without_enum, e[v].value)
        end
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
  alias_method :attr_enum, :attr_yinum
end

# Every module or class shall have it
class Module
  include Enum::Helpers::EnumAttribute
end
