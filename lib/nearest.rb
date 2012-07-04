class Time
  def nearest(seconds, opts={})
    method = opts[:force] ? (opts[:force] == :future ? 'ceil' : 'floor') : 'round'

    Time.at((self.to_f / seconds).send(method) * seconds)
  end
end
