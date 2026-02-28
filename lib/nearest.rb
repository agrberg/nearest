# frozen_string_literal: true

require_relative 'nearest/core'
require_relative 'nearest/time'
require_relative 'nearest/date_time'
require_relative 'nearest/time_with_zone' if defined?(ActiveSupport::TimeWithZone)
