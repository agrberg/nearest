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

### Anchoring

By default, rounding boundaries are relative to the Unix epoch. This works well for intervals that evenly divide 3600 (5, 10, 15, 20, 30, 60), but produces unintuitive results for other intervals (7, 8, 45, 90). A warning is emitted when an interval doesn't evenly divide 3600.

Use the `anchor:` keyword to choose a different reference point:

```ruby
# anchor: :hour — boundaries restart at the top of each hour
Nearest.new(Time.parse('1:10pm')).nearest(7 * 60, anchor: :hour).strftime('%-l:%M%P')
# => "1:07pm"  (grid: :00, :07, :14, :21, :28, :35, :42, :49, :56)

# anchor: :day — boundaries restart at local midnight
Nearest.new(Time.parse('1:10pm')).nearest(45 * 60, anchor: :day).strftime('%-l:%M%P')
# => "1:30pm"  (grid: 12:00am, 12:45am, 1:30am, 2:15am, 3:00am, ...)

# anchor: :epoch — explicit epoch-based rounding (no warning)
Nearest.new(Time.parse('1:10pm')).nearest(7 * 60, anchor: :epoch).strftime('%-l:%M%P')
```

The `anchor:` option works with all rounding modes and monkey patches:

```ruby
Time.parse('1:10pm').nearest(7 * 60, round: :down, anchor: :hour).strftime('%-l:%M%P')
# => "1:07pm"

# round: :prev crosses backward past the anchor point
Time.parse('1:00pm').nearest(7 * 60, round: :prev, anchor: :hour).strftime('%-l:%M%P')
# => "12:53pm"

# round: :next crosses forward past the end of the anchor period
Time.parse('1:56pm').nearest(7 * 60, round: :next, anchor: :hour).strftime('%-l:%M%P')
# => "2:03pm"

# Same with anchor: :day
Time.parse('12:00am').nearest(7 * 60, round: :prev, anchor: :day).strftime('%-l:%M%P')
# => "11:53pm"  (previous day)
```

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
