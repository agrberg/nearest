# frozen_string_literal: true

# Rounds a time-like object to the nearest interval.
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
class Nearest
  @warned_intervals = Set.new

  class << self
    def warn_once(seconds)
      int = seconds.to_i
      return if (3600 % int).zero?
      return unless @warned_intervals.add?(int)

      Kernel.warn "nearest: #{int}s does not evenly divide 3600; " \
                  'boundaries may not align with clock minutes. ' \
                  'Use anchor: :hour or anchor: :day for clock-aligned rounding'
    end

    def reset_warnings!
      @warned_intervals.clear
    end
  end

  def initialize(time)
    @time = time
  end

  def nearest(seconds, round: :nearest, anchor: nil)
    anchor_defaulted = anchor.nil?
    anchor ||= :epoch
    validate!(seconds, round, anchor)
    self.class.warn_once(seconds) if anchor_defaulted
    rebuild(rounded_epoch(seconds, round, anchor))
  end

  private

  def rounded_epoch(seconds, round, anchor) # rubocop:disable Metrics/CyclomaticComplexity
    base, offset = base_and_offset(anchor)
    quotient, remainder = offset.divmod(seconds)
    rounded = case round
              when :next    then quotient + 1                                       # always advance
              when :up      then remainder.zero? ? quotient : quotient + 1          # advance, unless exact
              when :nearest then remainder * 2 >= seconds ? quotient + 1 : quotient # round at midpoint
              when :down    then quotient                                           # truncate
              when :prev    then remainder.zero? ? quotient - 1 : quotient          # always retreat
              end
    base + (rounded * seconds)
  end

  def base_and_offset(anchor)
    case anchor
    when :epoch
      [0, @time.to_i]
    when :hour
      local_offset = (@time.min * 60) + @time.sec
      [@time.to_i - local_offset, local_offset]
    when :day
      local_offset = (@time.hour * 3600) + (@time.min * 60) + @time.sec
      [@time.to_i - local_offset, local_offset]
    end
  end

  def rebuild(epoch)
    if @time.respond_to?(:time_zone)
      Time.at(epoch).utc.in_time_zone(@time.time_zone)
    elsif @time.is_a?(DateTime)
      Time.at(epoch, in: @time.to_time.utc_offset).to_datetime
    else
      new_time = Time.at(epoch, in: @time.utc_offset)
      @time.utc? ? new_time.utc : new_time
    end
  end

  def validate!(seconds, round, anchor)
    raise ArgumentError, 'seconds must be a positive number' unless seconds.is_a?(Numeric) && seconds.positive?

    unless %i[next up nearest down prev].include?(round)
      raise ArgumentError, "round must be :next, :up, :nearest, :down, or :prev (got #{round.inspect})"
    end

    return if %i[epoch hour day].include?(anchor)

    raise ArgumentError, "anchor must be :epoch, :hour, or :day (got #{anchor.inspect})"
  end
end
