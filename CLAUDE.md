# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`nearest` is a Ruby gem that adds a `nearest` method to `Time`, allowing you to round a time to the nearest interval (e.g., nearest 15 minutes). Supports rounding to closest, forcing future, or forcing past.

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

The entire gem is a single file (`lib/nearest.rb`) that monkey-patches `Time#nearest`. It divides the time by the interval in seconds, rounds/ceils/floors, then multiplies back. Tests are in `spec/nearest_spec.rb` using RSpec.

## Linting

RuboCop is configured (`.rubocop.yml`) with plugins: `rubocop-performance`, `rubocop-rake`, `rubocop-rspec`. All new cops are enabled by default.
