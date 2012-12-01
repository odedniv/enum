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
