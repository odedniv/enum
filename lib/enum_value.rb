class EnumValue < BasicObject
  attr_reader :enum, :name, :value

  def initialize(enum, name, value)
    @enum, @name, @value = enum, name, value
  end

  def enum_value?
    true
  end

  def inspect
    "#{@enum.to_s}.#{@name}"
  end

  def ==(other)
    @name == other or @value == other
  end

  def ===(other)
    @name === other or @value === other
  end

  def t(options={})
    scope_without_klass = "enums.#{const_to_translation(@enum.name)}"
    if @enum.klass
      scope_with_klass = "enums.#{const_to_translation(@enum.klass.name)}.#{const_to_translation(@enum.name)}"
      return "I18n not available: #{scope_with_klass}.#{@name}" unless defined?(::I18n)

      ::I18n.t(@name,
               # prefer scope with klass
               options.reverse_merge(:scope => scope_with_klass,
                                     :default => ::I18n.t(@name,
                                                          # but if not, use without
                                                          options.reverse_merge(:scope => scope_without_klass,
                                                                                # but! if not, return scope with klass error
                                                                                :default => ::I18n.t(@name,
                                                                                                     options.reverse_merge(:scope => scope_with_klass))))))
    else
      return "I18n not available: #{scope_without_klass}.#{@name}" unless defined?(::I18n)

      ::I18n.t(@name, options.reverse_merge(:scope => scope_without_klass))
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
end
