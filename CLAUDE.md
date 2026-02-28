# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`nearest` is a Ruby gem that rounds `Time`, `DateTime`, or `ActiveSupport::TimeWithZone` to the nearest interval (e.g., nearest 15 minutes). Provides a standalone `Nearest` class and opt-in monkey patches. Supports five rounding modes (`:next`, `:up`, `:nearest` (default), `:down`, `:prev`) and an `anchor:` option (`:epoch`, `:hour`, `:day`) for clock-aligned rounding.

## Commands

- **Install dependencies:** `bundle install`
- **Run all checks (tests + lint):** `bundle exec rake`
- **Run tests:** `bundle exec rspec`
- **Run a single test file:** `bundle exec rspec spec/nearest_spec.rb`
- **Run a single test by line:** `bundle exec rspec spec/nearest_spec.rb:LINE`
- **Lint:** `bundle exec rubocop`
- **Lint with autofix:** `bundle exec rubocop -A`
- **Coverage report:** `bundle exec rake coverage`

## Architecture

The gem is organized under `lib/nearest/`:

- `lib/nearest.rb` — Entry point; requires core and monkey patch files
- `lib/nearest/core.rb` — Standalone `Nearest` class: converts time to epoch seconds, uses `divmod` to find interval boundaries, then picks the correct boundary based on the rounding mode
- `lib/nearest/time.rb` — Monkey patch adding `Time#nearest`
- `lib/nearest/date_time.rb` — Monkey patch adding `DateTime#nearest`
- `lib/nearest/time_with_zone.rb` — Monkey patch adding `ActiveSupport::TimeWithZone#nearest` (conditionally loaded)

Tests are in `spec/nearest/` with separate spec files for core, time, date_time, and time_with_zone. Uses RSpec.

## Linting

RuboCop is configured (`.rubocop.yml`) with plugins: `rubocop-performance`, `rubocop-rake`, `rubocop-rspec`. All new cops are enabled by default.

## CI

GitHub Actions CI (`.github/workflows/ci.yml`) runs on pushes to `main` and all pull requests. It lints with RuboCop and runs RSpec across Ruby 3.3, 3.4, and 4.0.

## Branching

The default branch is `main`.
