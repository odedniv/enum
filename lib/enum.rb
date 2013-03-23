class Enum
  require 'enum/enum_value'
  include Enumerable

  attr_reader :klass, :name, :by_name, :by_value

  def initialize(name, klass=nil, hash={})
    klass, hash = nil, klass if klass.is_a?(Hash)
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
  def each(&block)
    @by_name.each_value(&block)
  end

  def [](*name_or_values)
    return name_or_values.map { |name_or_value| self[name_or_value] } if name_or_values.length > 1

    name_or_value = name_or_values.first
    ev = @by_name_s[name_or_value.to_s] || @by_value_s[name_or_value.to_s]
    raise "#{inspect} does not know #{name_or_value.inspect}" if ev.nil?
    ev
  end

  private
  def map_hash(hash)
    @by_name = {}
    @by_value = {}
    @by_name_s = {}
    @by_value_s = {}
    hash.each do |n, v|
      n, v = v, n if v.is_a?(Symbol) or n.is_a?(Numeric)
      raise "duplicate enum name #{n} for #{to_s}" if @by_name.has_key?(n)
      raise "duplicate enum value #{v} for #{to_s}.#{n}" if @by_value.has_key?(v)
      raise "value can't be nil for #{to_s}.#{n}" if v.nil?
      @by_name_s[n.to_s] = @by_value_s[v.to_s] = @by_name[n] = @by_value[v] = EnumValue.new(self, n, v)
    end
    @by_name.freeze
    @by_value.freeze
  end
  def generate_methods
    names.each do |name|
      define_singleton_method(name) { self[name] }
    end
  end
end
