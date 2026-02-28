# frozen_string_literal: true

require_relative 'core'

module ActiveSupport
  class TimeWithZone # rubocop:disable Style/Documentation
    def nearest(seconds, round: :nearest, anchor: nil)
      Nearest.new(self).nearest(seconds, round:, anchor:)
    end
  end
end
