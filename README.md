# Nearest

[![CI](https://github.com/agrberg/nearest/actions/workflows/ci.yml/badge.svg)](https://github.com/agrberg/nearest/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/nearest.svg)](https://badge.fury.io/rb/nearest)

Round a `Time`, `DateTime`, or `ActiveSupport::TimeWithZone` to the nearest interval of minutes.

```ruby
Nearest.new(Time.parse('1:10pm')).nearest(15 * 60).strftime('%-l:%M%P')
# => "1:15pm"

Nearest.new(DateTime.parse('1:10pm')).nearest(15 * 60).strftime('%-l:%M%P')
# => "1:15pm"

# Also works with ActiveSupport::Duration and TimeWithZone
Nearest.new(Time.zone.parse('1:10pm')).nearest(15.minutes).strftime('%-l:%M%P')
# => "1:15pm"
```

### Require Paths

| Require path | What you get |
|---|---|
| `require 'nearest'` | `Nearest` class + all monkey patches (backward compatible) |
| `require 'nearest/core'` | Just the `Nearest` class |
| `require 'nearest/time'` | `Nearest` class + `Time#nearest` |
| `require 'nearest/date_time'` | `Nearest` class + `DateTime#nearest` |
| `require 'nearest/time_with_zone'` | `Nearest` class + `ActiveSupport::TimeWithZone#nearest` |

### Monkey Patches

If you prefer calling `nearest` directly on time objects, require the monkey patch for the class you need:

```ruby
require 'nearest/time'

Time.parse('1:10pm').nearest(15 * 60).strftime('%-l:%M%P')
# => "1:15pm"
```

Or require `nearest` to get all monkey patches at once (this is backward compatible with v1):

```ruby
require 'nearest'

Time.parse('1:10pm').nearest(15 * 60)
DateTime.parse('1:10pm').nearest(15 * 60)
Time.zone.parse('1:10pm').nearest(15 * 60) # if ActiveSupport is loaded
```

### Rounding Direction

By default, `nearest` rounds to the closest interval. You can control the direction with the `round` keyword:

```ruby
Nearest.new(Time.parse('1:06pm')).nearest(15 * 60, round: :up).strftime('%-l:%M%P')    # => "1:15pm"
Nearest.new(Time.parse('1:10pm')).nearest(15 * 60, round: :down).strftime('%-l:%M%P')  # => "1:00pm"
```

`:up` and `:down` stay put when already on a boundary. Use `:next` and `:prev` to always move:

```ruby
Nearest.new(Time.parse('1:00pm')).nearest(15 * 60, round: :up).strftime('%-l:%M%P')    # => "1:00pm" (already on boundary)
Nearest.new(Time.parse('1:00pm')).nearest(15 * 60, round: :next).strftime('%-l:%M%P')  # => "1:15pm" (always advances)
Nearest.new(Time.parse('1:00pm')).nearest(15 * 60, round: :prev).strftime('%-l:%M%P')  # => "12:45pm" (always retreats)
```

### Timezone Preservation

The returned time preserves the timezone of the input, including `ActiveSupport::TimeWithZone`:

```ruby
Nearest.new(Time.parse('1:10pm').utc).nearest(15 * 60).zone
# => "UTC"

Nearest.new(Time.parse('1:10pm').getlocal('+05:30')).nearest(15 * 60).utc_offset
# => 19800

Time.zone = 'Asia/Tokyo'
Nearest.new(Time.zone.parse('1:10pm')).nearest(15 * 60).time_zone.name
# => "Asia/Tokyo"
```

Rounding works correctly across DST boundaries. With `ActiveSupport::TimeWithZone`, the zone transitions naturally:

```ruby
Time.zone = 'Eastern Time (US & Canada)'

# Spring forward: 2:00am EST doesn't exist, rounds to 3:00am EDT
Nearest.new(Time.zone.parse('2026-03-08 01:53:00')).nearest(15 * 60).zone
# => "EDT"

# Fall back: 1:53am EDT advances across the transition to 1:00am EST
Nearest.new(Time.zone.parse('2026-11-01 01:53:00')).nearest(15 * 60).zone
# => "EST"
```

## Important

This is intended for minute durations that cleanly divide an hour (e.g., 5, 10, 15, 20, 30). Other intervals may produce unexpected results.

## Installation

Include it in your project's `Gemfile`:

```ruby
gem 'nearest'
```

To skip the monkey patches, change the require:

```ruby
gem 'nearest', require: 'nearest/core'
```

## License

MIT: https://mit-license.org/
