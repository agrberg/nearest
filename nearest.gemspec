# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'nearest'
  s.version     = '1.0.0'
  s.summary     = 'Round times to the nearest interval.'
  s.description = 'Round Time, DateTime, or ActiveSupport::TimeWithZone to the nearest interval. ' \
                  'Use the standalone Nearest class or opt-in monkey patches.'
  s.authors     = ['Aaron Rosenberg']
  s.email       = 'aarongrosenberg@gmail.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/agrberg/nearest'
  s.licenses    = ['MIT']
  s.metadata['rubygems_mfa_required'] = 'true'
  s.metadata['source_code_uri'] = 'https://github.com/agrberg/nearest'
  s.metadata['bug_tracker_uri'] = 'https://github.com/agrberg/nearest/issues'

  s.required_ruby_version = '>= 3.3'
end
