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
require "crabfarm/base_navigator"
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
    # bundled browser adapters
    register :browser, :phantomjs, 'Crabfarm::Adapters::Browser::PhantomJs', dependencies: ['selenium-webdriver']
    register :browser, :firefox, 'Crabfarm::Adapters::Browser::Firefox', dependencies: ['selenium-webdriver']
    register :browser, :chrome, 'Crabfarm::Adapters::Browser::Chrome', dependencies: ['selenium-webdriver']
    register :browser, :remote, 'Crabfarm::Adapters::Browser::RemoteWebdriver', dependencies: ['selenium-webdriver']
    register :browser, :noop, 'Crabfarm::Adapters::Browser::Noop'

    # bundled webdriver dsl adapters
    register :webdriver_dsl, :surfer, 'Crabfarm::Adapters::DriverWrapper::Surfer'
    register :webdriver_dsl, :watir, 'Crabfarm::Adapters::DriverWrapper::Watir', dependencies: ['watir-webdriver']
    register :webdriver_dsl, :capybara, 'Crabfarm::Adapters::DriverWrapper::Capybara', dependencies: ['capybara']

    # bundled parsers dsl adapters
    register :parser, :nokogiri, 'Crabfarm::Adapters::Parser::Nokogiri', dependencies: ['nokogiri']
    register :parser, :pdf_reader, 'Crabfarm::Adapters::Parser::PdfReader', dependencies: ['pdf-reader']

    # bundled state output builders
    register :output_builder, :hash, 'Crabfarm::Adapters::Output::Hash'
    register :output_builder, :ostruct, 'Crabfarm::Adapters::Output::OStruct'
    register :output_builder, :jbuilder, 'Crabfarm::Adapters::Output::Jbuilder', dependencies: ['jbuilder']
  end
end
