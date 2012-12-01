class EnumValue < BasicObject
  attr_reader :enum, :name, :value

  def initialize(enum, name, value)
    @enum, @name, @value = enum, name, value
  end

  def inspect
    "#{@enum.to_s}.#{@name}"
  end

  def ==(other)
    case other
      when ::Symbol then @name  == other
      else               @value == other
    end
  end

  def ===(other)
    case other
      when ::Symbol then @name  === other
      else               @value === other
    end
  end

  def t(options={})
    default = ::I18n.t(@name, options.merge(:scope => "enums.#{@enum.name}"))
    if @enum.klass
      ::I18n.t(@name, options.merge(:scope => "enums.#{@enum.klass.name}.#{@enum.name}", :default => default))
    else
      default
    end
  end

  def methods
    super + @value.methods
  end

  def method_missing(method, *args, &block)
    match = method.to_s.match(/^(.+)\?$/)
    enum_name = match[1].to_sym if match
    if @enum.names.include?(enum_name)
      @name.==(enum_name, *args, &block)
    elsif @value.respond_to?(method)
      @value.send(method, *args, &block)
    else
      super
    end
  end
end

class Enum
  attr_reader :klass, :name, :by_name, :by_value
  
  def initialize(name, hash={}, klass=nil)
    @name, @klass = name, klass
    map_hash(hash)
    generate_methods
  end

  def to_s
    @klass ? "#{@klass.name}::#{@name}" : @name.to_s
  end
  def inspect
    "#{to_s}(#{@by_name.map { |n,ev| "#{n.inspect} => #{ev.value.inspect}"}.join(", ")})"
  end

  def names
    @by_name.keys
  end
  def values
    @by_value.keys
  end

  def [](name_or_value)
    ev = name_or_value.is_a?(Symbol) ? @by_name[name_or_value] : @by_value[name_or_value]
    raise "#{inspect} does not know #{name_or_value.inspect}" if ev.nil?
    ev
  end

  private
  def map_hash(hash)
    @by_name = {}
    @by_value = {}
    hash.each do |n, v|
      n, v = v, n if v.is_a?(Symbol)
      raise "duplicate enum name #{n} for #{to_s}" if @by_name.has_key?(n)
      raise "duplicate enum value #{v} for #{to_s}.#{n}" if @by_value.has_key?(v)
      raise "value can't be nil for #{to_s}.#{n}" if v.nil?
      @by_name[n] = @by_value[v] = EnumValue.new(self, n, v)
    end
  end
  def generate_methods
    names.each do |name|
      define_singleton_method(name) { self[name] }
    end
  end
end

module EnumGenerator
  def enum(name, hash)
    const_set name, Enum.new(name, hash, self)
  end
end

class Object
  extend EnumGenerator
end

module EnumColumns
  # Bind a column to an enum by:
  #   Generating attribute reader and writer to convert to EnumValue.
  #   Creating a validation for the attribute so it must have valid enum values (allowing nil).
  #   If :scoped => true, generates scopes and questioning methods for every name in the enum.
  # If given a enum name (a symbol) and hash, also creates the enum.
  def enum_column(attr, name_or_enum, hash={})
    scoped = hash.delete(:scoped)
    # generating or getting the enum
    if name_or_enum.is_a?(Symbol)
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
    validates attr, :inclusion => { :in => e.values }, :allow_nil => true
    if scoped
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
