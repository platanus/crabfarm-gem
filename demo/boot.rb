require 'bundler'

# Load gems listed in the Gemfile.

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __FILE__)
Bundler.setup
require 'crabfarm'

# Run code loader

CF_PATH = File.expand_path('../', __FILE__)
CF_LOADER = Crabfarm::Loader.new CF_PATH
