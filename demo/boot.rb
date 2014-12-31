# Load gems listed in the Gemfile.

require 'bundler'

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __FILE__)
require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

Bundler.require

# Run code loader

CF_PATH = File.expand_path('../', __FILE__)
CF_LOADER = Crabfarm::Loader.new CF_PATH
