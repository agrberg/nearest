# frozen_string_literal: true

# Adds `Time#nearest` to round a time to the nearest interval
class Time
  def nearest(seconds, force: nil)
    method = if force
               force == :future ? :ceil : :floor
             else
               :round
             end

    new_time = Time.at((to_f / seconds).public_send(method) * seconds)
    utc? ? new_time.utc : new_time
  end
end
