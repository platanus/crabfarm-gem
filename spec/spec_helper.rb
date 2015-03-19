require 'pry'
require 'crabfarm'
require 'fakefs/spec_helpers'
require 'crabfarm-mocks'

FIXTURE_PATH = File.expand_path('../support', __FILE__)

RSpec.configure do |config|
  config.before(:context) { Crabfarm.config.reset }
  config.before(:example) { Crabfarm.config.reset }
end