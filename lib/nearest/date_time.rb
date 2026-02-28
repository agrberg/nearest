# frozen_string_literal: true

# DateTime inherits from Date, not Time, so it needs its own nearest.
# Converts to Time, rounds, then converts back to DateTime.
class DateTime
  def nearest(seconds, round: :nearest)
    to_time.nearest(seconds, round:).to_datetime
  end
end
