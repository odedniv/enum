# Enum

A straightforward implementation of an enum for Ruby (on Rails).

The straightforward usage looks like this:

    COLORS = Enum.new(:COLORS, :red => 1, :green => 2, :blue => 3)
    COLORS.red
    => COLORS.red
    COLORS.red == 1 && COLORS.red == :red
    => true

## Getting started

    $ gem install enum

Or in your Gemfile:

    gem "enum"

## Usage

Creating an enum:

    FRUITS = Enum.new(:FRUITS, :apple => 1, :orange => 2)
    => FRUITS(:apple => 1, :orange => 2)

Creating an enum with a parent class:

    class Car
      COLORS = Enum.new(:COLORS, Car, :red => 1, :black => 2)
    end
    => Car::COLORS(:red => 1, :black => 2)

Another way, with the helper method:

    class Car
      enum :COLORS, 1 => :red, 2 => :black
    end
    => Car::COLORS(:red => 1, :black => 2)

(Can go either KEY => VALUE or VALUE => KEY as long as the key is a Symbol or the value is a Numeric).

Getting enum values:

    FRUITS.apple
    => FRUITS.apple
    FRUITS[:apple]
    => FRUITS.apple
    FRUITS[1]
    => FRUITS.apple

Comparing enum values:

    fruit = FRUITS.orange
    => FRUITS.orange
    fruit == 2
    => true
    fruit == :orange
    => true
    fruit.apple?
    => false

The enum value is actually a delegate to the value with a special inspect and comparison:

    fruit = FRUITS.orange
    => FRUITS.orange
    fruit.to_i
    => 2
    fruit + 1
    => 3
    fruit > FRUITS.apple
    => true

How the enum gets along with Rails, assuming the following model:

    # == Schema Info
    #
    # Table name: cars
    #
    #  id                  :integer(11)    not null, primary key
    #  color               :integer(11)
    #

    class Car < ActiveRecord::Base
      enum_column :color, :COLORS, :red => 1, :black => 2
    end

Now the `color` column is always read and written using the enum value feature:

    Car.create! :color => :red
    => #<Car id: 1, color: 1>
    Car.last.color.red?
    => true

This also creates a `validates\_inclusion\_of` with `allow\_nil => true` to prevent having bad values.

Adding another `:scoped => true` option before the enum values allows automatic generation of scopes and question
methods on the model as follows:

    class Car < ActiveRecord::Base
      enum_column :color, :COLORS, { :scoped => true }, :red => 1, :black => 2
    end
    Car.red.to_sql
    => "SELECT `cars`.* FROM `cars` WHERE `cars`.`color` = 1"
    Car.last.red?
    => true

Last but not least, automatic translation lookup.
Given the following `config/locales/en.yml`:

    en:
      enums:
        fruits:
          apple: Green Apple
          orange: Orange Color
        colors:
          red: Shiny Red
          black: Blackest Black
        car:
          colors:
            black: Actually, white

The following will occur:

    FRUITS.apple.t
    => "Green Apple"
    FRUITS[2].t
    => "Orange Color"
    Car::COLORS.red
    => "Shiny Red"
    Car::COLORS.black
    => "Actually, white"

When the enum is given a parent, the class's name is used in the translation.
If the translation is missing, it fallbacks to the translation without the class's name.

All enum names (usually CONSTANT\_LIKE) and parent class names are converted to snakecase.

== Limitations

Since the `===` operator is called on the when value, this syntax cannot be used:

    case fruit
      when :red then "This will never happen!"
    end

The following should be used instead:

    case fruit
      when FRUITS.red then "This is better..."
    end

This is because I had trouble overriding the `===` operator of the Symbol class.

