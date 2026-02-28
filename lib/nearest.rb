# frozen_string_literal: true

# Adds `Time#nearest` to round a time to the nearest interval.
#
# The algorithm converts time to epoch seconds, then uses divmod to split into
# whole intervals (quotient) and leftover seconds (remainder). Multiplying the
# quotient back by the interval gives the earlier boundary; quotient + 1 gives
# the later boundary. The remainder decides which one to pick.
#
# Example: 1:10pm rounded to 15-minute intervals (900 seconds)
#
#   epoch_seconds = 47400  (seconds since midnight for 1:10pm)
#   quotient, remainder = 47400.divmod(900)  # => [52, 600]
#
#   quotient * 900     = 46800  => 1:00pm  (earlier boundary)
#   (quotient + 1) * 900 = 47700  => 1:15pm  (later boundary)
#   remainder = 600  (10 minutes past the earlier boundary)
#
#   round: :next    => quotient + 1 => 1:15pm  (always advances, even from a boundary)
#   round: :up      => quotient + 1 => 1:15pm
#   round: :nearest => 600 * 2 >= 900, so quotient + 1 => 1:15pm
#   round: :down    => quotient     => 1:00pm
#   round: :prev    => quotient     => 1:00pm  (always retreats, even from a boundary)
class Time
  def nearest(seconds, round: :nearest)
    validate_nearest_args!(seconds, round)

    new_time = Time.at(nearest_epoch(seconds, round))
    utc? ? new_time.utc : new_time
  end

  private

  def nearest_epoch(seconds, round) # rubocop:disable Metrics/CyclomaticComplexity
    quotient, remainder = to_i.divmod(seconds)
    rounded = case round
              when :next    then quotient + 1                                       # always advance
              when :up      then remainder.zero? ? quotient : quotient + 1          # advance, unless exact
              when :nearest then remainder * 2 >= seconds ? quotient + 1 : quotient # round at midpoint
              when :down    then quotient                                           # truncate
              when :prev    then remainder.zero? ? quotient - 1 : quotient          # always retreat
              end
    rounded * seconds
  end

  def validate_nearest_args!(seconds, round)
    raise ArgumentError, 'seconds must be a positive number' unless seconds.is_a?(Numeric) && seconds.positive?
    return if %i[next up nearest down prev].include?(round)

    raise ArgumentError, "round must be :next, :up, :nearest, :down, or :prev (got #{round.inspect})"
  end
end
