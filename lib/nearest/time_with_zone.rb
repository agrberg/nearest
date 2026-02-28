# frozen_string_literal: true

# TimeWithZone#method_missing delegates to an internal wall-clock Time whose to_i
# differs from the real epoch, producing wrong results across DST boundaries.
# Defining nearest directly avoids this by going through UTC first.
module ActiveSupport
  class TimeWithZone # rubocop:disable Style/Documentation
    def nearest(seconds, round: :nearest)
      utc.nearest(seconds, round:).in_time_zone(time_zone)
    end
  end
end
