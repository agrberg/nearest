# `Time#nearest`

[![CI](https://github.com/agrberg/nearest/actions/workflows/ci.yml/badge.svg)](https://github.com/agrberg/nearest/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/nearest.svg)](https://badge.fury.io/rb/nearest)

`nearest` adds a `nearest` method to `Time`, `DateTime`, and `ActiveSupport::TimeWithZone`, allowing you to round a time to the nearest interval of minutes.

```ruby
Time.parse('1:10pm').nearest(15 * 60).strftime('%-l:%M%P')
# => "1:15pm"

DateTime.parse('1:10pm').nearest(15 * 60).strftime('%-l:%M%P')
# => "1:15pm"

# Also works with ActiveSupport::Duration
Time.parse('1:10pm').nearest(15.minutes).strftime('%-l:%M%P')
# => "1:15pm"
```

### Rounding Direction

By default, `nearest` rounds to the closest interval. You can control the direction with the `round` keyword:

```ruby
Time.parse('1:06pm').nearest(15 * 60, round: :up).strftime('%-l:%M%P')    # => "1:15pm"
Time.parse('1:10pm').nearest(15 * 60, round: :down).strftime('%-l:%M%P')  # => "1:00pm"
```

`:up` and `:down` stay put when already on a boundary. Use `:next` and `:prev` to always move:

```ruby
Time.parse('1:00pm').nearest(15 * 60, round: :up).strftime('%-l:%M%P')    # => "1:00pm" (already on boundary)
Time.parse('1:00pm').nearest(15 * 60, round: :next).strftime('%-l:%M%P')  # => "1:15pm" (always advances)
Time.parse('1:00pm').nearest(15 * 60, round: :prev).strftime('%-l:%M%P')  # => "12:45pm" (always retreats)
```

### Timezone Preservation

The returned time preserves the timezone of the input, including `ActiveSupport::TimeWithZone`:

```ruby
Time.parse('1:10pm').utc.nearest(15 * 60).zone
# => "UTC"

Time.parse('1:10pm').getlocal('+05:30').nearest(15 * 60).utc_offset
# => 19800

Time.zone = 'Asia/Tokyo'
Time.zone.parse('1:10pm').nearest(15 * 60).time_zone.name
# => "Asia/Tokyo"
```

Rounding works correctly across DST boundaries. With `ActiveSupport::TimeWithZone`, the zone transitions naturally:

```ruby
Time.zone = 'Eastern Time (US & Canada)'

# Spring forward: 2:00am EST doesn't exist, rounds to 3:00am EDT
Time.zone.parse('2026-03-08 01:53:00').nearest(15 * 60).zone
# => "EDT"

# Fall back: 1:53am EDT advances across the transition to 1:00am EST
Time.zone.parse('2026-11-01 01:53:00').nearest(15 * 60).zone
# => "EST"
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
