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
      COLORS = Enum.new(:COLORS, { :red => 1, :black => 2 }, Car)
    end
    => Car::COLORS(:red => 1, :black => 2)

Another way, with a the helper:

    class Car
      enum :COLORS, 1 => :red, 2 => :black
    end
    => Car::COLORS(:red => 1, :black => 2)

(Can go either KEY => VALUE or VALUE => KEY as long as the key is a Symbol).

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

    class Car < ActiveRecord::Base
      enum_column :color, :COLORS, :red => 1, :black => 2
    end

Now the `color` column is always read and written using the enum value feature:

    Car.create! :color => :red
    => #<Car id: 1, color: 1>
    Car.last.color.red?
    => true
