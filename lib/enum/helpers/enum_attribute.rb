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
      no_reader = true
    end
    define_method(reader) do
      v = no_reader ? super() : send(reader_without_enum)
      (ev = e.get(v)).nil? ? Enum::EnumValue.new(e, v) : ev
    end
    # attribute writer
    writer, writer_without_enum = :"#{attr}=", :"#{attr}_without_enum="
    begin
      alias_method writer_without_enum, writer
    rescue NameError # writer does not exist
      no_writer = true
    end
    define_method(writer) do |v|
      v = case
            when v.enum_value? then v.value
            # might be received from forms
            when v.nil?, v == "" then v
            else e[v].value
          end
      no_writer ? super(v) : send(writer_without_enum, v)
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
