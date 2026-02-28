# `Time#nearest`

[![CI](https://github.com/agrberg/nearest/actions/workflows/ci.yml/badge.svg)](https://github.com/agrberg/nearest/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/nearest.svg)](https://badge.fury.io/rb/nearest)

`nearest` extends Ruby's `Time` class with a `nearest` method, allowing you to round a time to the nearest interval of minutes.

```ruby
Time.parse('1:10pm').nearest(15 * 60)
# => 1:15pm
```

### Rounding Direction

By default, `nearest` rounds to the closest interval. You can control the direction with the `round` keyword:

```ruby
Time.parse('1:06pm').nearest(15 * 60, round: :up)
# => 1:15pm

Time.parse('1:10pm').nearest(15 * 60, round: :down)
# => 1:00pm
```

### Timezone Preservation

The returned time preserves the timezone of the input:

```ruby
Time.parse('1:10pm').utc.nearest(15 * 60).zone
# => "UTC"
```

## Important

This is intended for minute durations that cleanly divide an hour (e.g., 5, 10, 15, 20, 30). Other intervals may produce unexpected results.

## Installation

Include it in your project's `Gemfile`:

```ruby
gem 'nearest'
```

## License

MIT: https://mit-license.org/
