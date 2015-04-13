require "logger"
require "forwardable"
require "net/http"
require "active_support/inflector"

require "crabfarm/version"
require "crabfarm/errors"
require "crabfarm/configuration"
require "crabfarm/global_state"
require "crabfarm/driver_pool"
require "crabfarm/http_client"
require "crabfarm/phantom_runner"
require "crabfarm/state_store"
require "crabfarm/context"
require "crabfarm/context_factory"
require "crabfarm/transition_service"
require "crabfarm/base_state"
require "crabfarm/base_parser"
require "crabfarm/strategies"

require "crabfarm/utils/port_discovery"
require "crabfarm/utils/naming"

module Crabfarm

  @@config = Configuration.new
  @@logger = nil

  def self.config
    @@config
  end

  def self.logger
    if @@logger.nil?
      @@logger = Logger.new(@@config.log_path.nil? ? STDOUT : File.join(@@config.log_path, 'crawler.log'))
      @@logger.level = Logger::INFO
    end
    @@logger
  end

  def self.read_crabfile(_path)
    @@config.instance_eval File.read _path
  end

  module Strategies
    # bundled navigation driver adapters
    register :driver, :phantomjs, 'Crabfarm::Adapters::Drivers::PhantomJs', dependencies: ['selenium-webdriver']
    register :driver, :firefox, 'Crabfarm::Adapters::Drivers::Firefox', dependencies: ['selenium-webdriver']
    register :driver, :chrome, 'Crabfarm::Adapters::Drivers::Chrome', dependencies: ['selenium-webdriver']
    register :driver, :remote, 'Crabfarm::Adapters::Drivers::RemoteWebdriver', dependencies: ['selenium-webdriver']
    register :driver, :noop, 'Crabfarm::Adapters::Drivers::Noop'

    # bundled webdriver dsl adapters
    register :webdriver_dsl, :surfer, 'Crabfarm::Adapters::Browser::Surfer'
    register :webdriver_dsl, :watir, 'Crabfarm::Adapters::Browser::Watir', dependencies: ['watir-webdriver']
    register :webdriver_dsl, :capybara, 'Crabfarm::Adapters::Browser::Capybara', dependencies: ['capybara']

    # bundled parsers dsl adapters
    register :parser_engine, :nokogiri, 'Crabfarm::Adapters::Parser::Nokogiri', dependencies: ['nokogiri']
    register :parser_engine, :pdf_reader, 'Crabfarm::Adapters::Parser::PdfReader', dependencies: ['pdf-reader']

    # bundled state output builders
    register :output_builder, :hash, 'Crabfarm::Adapters::Output::Hash'
    register :output_builder, :ostruct, 'Crabfarm::Adapters::Output::OStruct'
    register :output_builder, :jbuilder, 'Crabfarm::Adapters::Output::Jbuilder', dependencies: ['jbuilder']
  end
end
