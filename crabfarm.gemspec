# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crabfarm/version'

Gem::Specification.new do |spec|
  spec.name          = "crabfarm"
  spec.version       = Crabfarm::VERSION
  spec.authors       = ["Ignacio Baixas"]
  spec.email         = ["ignacio@platan.us"]
  spec.summary       = "Crabfarm crawler creation framework"
  spec.homepage      = "https://github.com/platanus/crabfarm-gem"
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/*'] + Dir['bin/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'jbuilder', "~> 2.2.0"
  spec.add_dependency 'selenium-webdriver', "~> 2.33"
  spec.add_dependency 'capybara'
  spec.add_dependency 'watir-webdriver'
  spec.add_dependency 'nokogiri', '~> 1.6.6'
  spec.add_dependency 'activesupport', '>= 3.0.0', '< 5'
  spec.add_dependency 'gli','~> 2.12.0'
  spec.add_dependency 'rainbow','~> 2.0.0'
  spec.add_dependency 'grape','~> 0.10.0'
  spec.add_dependency 'puma','~> 2.10.2'
  spec.add_dependency 'git'
  spec.add_dependency 'multipart-post'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-nc"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "terminal-notifier-guard", '~> 1.6.1'
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-remote"
  spec.add_development_dependency "pry-nav"
end
