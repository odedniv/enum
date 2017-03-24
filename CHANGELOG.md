**2.2.1**
* Fix ==(=) for Ruby 2.4.

**2.2.1**
* Fix `validates_inclusion_of` for Ruby 2.4.

**2.2.0**
* `EnumValue` compares to strings.

**2.1.0**
* Use generate_method in attr_enum. This is backward incompatible for using
  attr_enum on accessors defined on the class level. Use modules.

**2.0.0**
* Use `#alias_attr` instead of calling super in `Enum::Helpers::EnumAttribute`.
* Allow valueless enums (given with `Array` instead of `Hash`), that map to the
  string of the key.

**1.8.1**
* Oops, merge 1.7.5 into 1.8.

**1.8.0**
* `Enum#options` now return the mapping of translations to their corresponding
  values rather than their names. Works better with `FormBuilder`.

**1.7.5**
* Alias helper methods to support Rails 4.1 overriding `::enum`.

**1.7.4**
* `attr_enum`'s reader allows super to hold the name etc.
* Add `#attr_enum` and `#enum` only to modules and classes (not any instance).

**1.7.3**
* `attr_enum`'s writer to accept empty string.
* `attr_enum`'s qualifier option to use the object's `#send` rather than `#[]`.

**1.7.2**
* Added `Object#enum_value?` to fix `attr_enum`'s writer, `BasicObject` does
  not have `respond_to?`.
* Fix specs that didn't catch above bug.

**1.7.1**
* Remove usage of `reverse_merge`, apparently doesn't exist in Ruby core.
* `attr_enum`'s writer does not pass an `EnumValue` to the super.
* Fix `EnumValue#t` specs (mocking `I18n`).

**1.7.0**
* `attr_enum` reader always returns an EnumValue.
* `EnumValue#t` uses `String#titlelize` if it's available and I18n or the
  specific translation are not available.
