# Architecture

## Overview

`nearest` rounds `Time`, `DateTime`, or `ActiveSupport::TimeWithZone` objects to a given interval. It has zero runtime dependencies and is ~105 lines of implementation code.

## File Structure

```
lib/
  nearest.rb                  # Entry point — requires core + monkey patches
  nearest/
    core.rb                   # Nearest class (algorithm + rebuild logic)
    time.rb                   # Time#nearest monkey patch
    date_time.rb              # DateTime#nearest monkey patch
    time_with_zone.rb         # ActiveSupport::TimeWithZone#nearest (conditional)
```

## Core Algorithm (`lib/nearest/core.rb`)

The rounding algorithm works in three steps:

### 1. Convert to offset seconds

Depending on the anchor mode, compute a `base` (reference epoch) and `offset` (seconds since that reference):

| Anchor    | Base                        | Offset                          |
|-----------|-----------------------------|---------------------------------|
| `:epoch`  | 0                           | Full epoch seconds              |
| `:hour`   | Start of current hour       | Seconds within the hour         |
| `:day`    | Local midnight              | Seconds since midnight          |

### 2. Divide by interval

```ruby
quotient, remainder = offset.divmod(seconds)
```

`quotient` locates the interval slot, `remainder` is how far past that slot boundary the time falls.

### 3. Pick the boundary

The rounding mode selects which slot boundary to use:

| Mode       | Rule                                           |
|------------|-------------------------------------------------|
| `:next`    | Always advance: `quotient + 1`                  |
| `:up`      | Advance unless on boundary: `remainder.zero? ? quotient : quotient + 1` |
| `:nearest` | Midpoint round: `remainder * 2 >= seconds ? quotient + 1 : quotient`    |
| `:down`    | Truncate: `quotient`                            |
| `:prev`    | Always retreat: `remainder.zero? ? quotient - 1 : quotient`             |

The final epoch value is `base + chosen_quotient * seconds`, which gets rebuilt into the original time type.

### Rebuild

`rebuild` reconstructs the correct time type from epoch seconds, preserving timezone/offset:

- **Time** — `Time.at(epoch, in: utc_offset)`, preserving UTC status
- **DateTime** — `Time.at(epoch, in: utc_offset).to_datetime`
- **TimeWithZone** — `Time.at(epoch).utc.in_time_zone(original_zone)`

## Monkey Patches

Each patch file adds a `#nearest` instance method that delegates to the core class:

```ruby
def nearest(seconds, **options)
  Nearest.new(self).nearest(seconds, **options)
end
```

`time_with_zone.rb` is only loaded if `ActiveSupport::TimeWithZone` is defined at require time.

## Requiring

- `require "nearest"` — Loads core + all monkey patches (TimeWithZone conditionally)
- `require "nearest/core"` — Loads only the `Nearest` class, no monkey patches

## Warning System

When an interval doesn't divide 3600 evenly and no explicit `anchor:` is provided, a one-time warning per interval is emitted to stderr. This alerts users that epoch-anchored rounding may produce non-intuitive clock alignments. Tracked via a class-level `Set`.

## Tests

```
spec/
  spec_helper.rb              # SimpleCov (opt-in), SuppressWarnings helper
  nearest/
    core_spec.rb              # Algorithm, type preservation, anchors, validation
    time_spec.rb              # Time#nearest, DST boundaries, intervals
    date_time_spec.rb         # DateTime#nearest, offset preservation, DST
    time_with_zone_spec.rb    # TimeWithZone#nearest, named zones, DST
```

## CI

Two parallel GitHub Actions jobs on push to `main` and all PRs:

1. **Lint** — RuboCop on Ruby 3.3
2. **Test** — RSpec across Ruby 3.3, 3.4, and 4.0 (fail-fast disabled)
