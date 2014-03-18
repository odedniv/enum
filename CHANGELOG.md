**1.7.0**
* `attr_enum` reader always returns an EnumValue.
* `EnumValue#t` uses `String#titlelize` if it's available and I18n or the
  specific translation are not available.

**1.7.1**
* Remove usage of `reverse_merge`, apparently doesn't exist in Ruby core.
* `attr_enum`'s writer does not pass an EnumValue to the super.
* Fix `EnumValue#t` specs (mocking `I18n`).
