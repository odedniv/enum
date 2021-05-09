class Object
  def enum_value?
    false
  end
end

class Enum::EnumValue < BasicObject
  attr_reader :enum, :name, :value

  def initialize(enum, name = nil, value)
    @enum, @name, @value = enum, name, value
    @name_s = @name.to_s if @name
    @value_s = @value.to_s
  end

  def enum_value?
    true
  end

  def inspect
    return @value.inspect if @name.nil?

    "#{@enum.to_s}.#{@name_s}"
  end

  def ==(other)
    return true if super
    return true if @value == other or @value_s == other

    not @name.nil? and (@name == other or @name_s == other)
  end

  def ===(other)
    return true if self == other or super
    return true if @value === other or @value_s === other

    not @name.nil? and (@name === other or @name_s === other)
  end

  def t(options = {})
    return @value.t(options) if @name.nil?
    if not defined?(::I18n)
      if @name_s.respond_to?(:titleize)
        return @name_s.titleize
      else
        raise NotImplementedError, "I18n and String#titleize are not available"
      end
    end

    scope_without_klass = "enums.#{const_to_translation(@enum.name)}"
    if @enum.klass
      scope_with_klass = "enums.#{const_to_translation(@enum.klass.name)}.#{const_to_translation(@enum.name)}"

      ::I18n.t(
        @name,
        # prefer scope with klass
        { scope: scope_with_klass
        }.merge(options).merge( # our :default is a priority here
          default: ::I18n.t(
            @name,
            # but if not, use without
            { scope: scope_without_klass,
              # but! if not, return titleize or scope with klass error
              default: @name_s.respond_to?(:titleize) ? @name_s.titleize : ::I18n.t(
                @name,
                { scope: scope_with_klass
                }.merge(options)
              )
            }.merge(options)
          )
        )
      )
    else
      ::I18n.t(
        @name,
        { scope: scope_without_klass,
          default: (@name_s.titleize if @name_s.respond_to?(:titleize))
        }.merge(options)
      )
    end
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

  def respond_to_missing?(method, *)
    method.to_s == 'to_ary' ? false : super
  end

  private
  def const_to_translation(name)
    # From Rails' ActiveSupport String#underscore
    name.to_s.
      gsub(/::/, '.').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end

  # Useful modules
  begin
    require 'nil_or'
  rescue ::LoadError
  else
    include ::NilOr::Methods
  end
end
