# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'nearest'
  s.version     = '1.0.0'
  s.summary     = 'Find the nearest X minutes to a given time.'
  s.description = 'Adds `Time#nearest` for rounding to the closest time interval.'
  s.authors     = ['Aaron Rosenberg']
  s.email       = 'aarongrosenberg@gmail.com'
  s.files       = ['lib/nearest.rb']
  s.homepage    = 'https://github.com/agrberg/nearest'
  s.licenses    = ['MIT']
  s.metadata['rubygems_mfa_required'] = 'true'
  s.metadata['source_code_uri'] = 'https://github.com/agrberg/nearest'
  s.metadata['bug_tracker_uri'] = 'https://github.com/agrberg/nearest/issues'

  s.required_ruby_version = '>= 3.3'
end
