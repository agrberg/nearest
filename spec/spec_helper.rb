# frozen_string_literal: true

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require 'time'
# ActiveSupport must be loaded before nearest so that nearest can patch TimeWithZone.
require 'active_support/isolated_execution_state' # Needed by Time.zone= for thread-safe per-fiber state.
require 'active_support/time' # Adds Numeric#minutes, Time.zone=, and TimeWithZone for named time zone support.
require_relative '../lib/nearest'
