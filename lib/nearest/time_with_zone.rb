# frozen_string_literal: true

require_relative 'core'

module ActiveSupport
  class TimeWithZone # rubocop:disable Style/Documentation
    def nearest(seconds, round: :nearest)
      Nearest.new(self).nearest(seconds, round:)
    end
  end
end
