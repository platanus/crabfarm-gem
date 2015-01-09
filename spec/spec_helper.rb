require 'pry'
require 'crabfarm'
require 'surimi'

FIXTURE_PATH = File.expand_path('../support', __FILE__)

RSpec.configure do |config|
  config.before(:context) { Crabfarm.config.reset }
  config.before(:example) { Crabfarm.config.reset }
end