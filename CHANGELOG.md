* `attr_enum` reader always returns an EnumValue.
* `EnumValue#t` uses `String#titlelize` if it's available and I18n or the
  specific translation are not available.