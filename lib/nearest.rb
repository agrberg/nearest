class Time
  def nearest(seconds, opts={})
    method = opts[:force] ? (opts[:force] == :future ? 'ceil' : 'floor') : 'round'

    new_time = Time.at((self.to_f / seconds).send(method) * seconds)
    utc? ? new_time.utc : new_time
  end
end
