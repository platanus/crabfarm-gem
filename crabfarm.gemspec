# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "crabfarm/version"

Gem::Specification.new do |spec|
  spec.name          = "crabfarm"
  spec.version       = Crabfarm::VERSION
  spec.authors       = ["Ignacio Baixas"]
  spec.email         = ["ignacio@platan.us"]
  spec.summary       = "Crabfarm is a TDD oriented web scrapping framework"
  spec.description   = %{
    Crabfarm lets you build web scrappers using TDD, it is also very opinionated about
    the way a scrapper should be structured. Scrappers created by crabfarm can be hosted
    and monitored in the Crabfarm grid infrastructure.
  }
  spec.homepage      = "https://github.com/platanus/crabfarm-gem"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + Dir["bin/**/*"] + Dir["assets/**/*"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 3.0", "< 5"
  spec.add_dependency "gli", "~> 2.12"
  spec.add_dependency "inquirer", "~> 0.2"
  spec.add_dependency "rainbow", "~> 2.0"
  spec.add_dependency "grape", "~> 0.10"
  spec.add_dependency "puma", "~> 2.10", ">= 2.10.2"
  spec.add_dependency "git", "~> 1.2"
  spec.add_dependency "childprocess", "~> 0.5", ">= 0.5.5"
  spec.add_dependency "listen", "~> 2.7"
  spec.add_dependency "pry-byebug", "~> 3.2"
  spec.add_dependency "linedump", "~> 0.1"

  spec.add_development_dependency "selenium-webdriver", "~> 2.47"
  spec.add_development_dependency "nokogiri", "~> 1.6", ">= 1.6.6"
  spec.add_development_dependency "pincers", "~> 0.7"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.4"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "rspec-nc", "~> 0.2"
  spec.add_development_dependency "guard", "~> 2.11"
  spec.add_development_dependency "guard-rspec", "~> 4.5"
  spec.add_development_dependency "terminal-notifier-guard", "~> 1.6", ">= 1.6.1"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "pry-remote", "~> 0.1"
  spec.add_development_dependency "pry-nav", "~> 0.2"

  spec.add_development_dependency "pdf-reader", "~> 1.3", ">= 1.3.3"
  spec.add_development_dependency "watir-webdriver", "~> 0.7"
  spec.add_development_dependency "jbuilder", "~> 2.2"
  spec.add_development_dependency "fakefs", "~> 0.6", ">= 0.6.7"
end
