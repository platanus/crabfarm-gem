require "logger"
require "forwardable"
require "net/http"
require "active_support/inflector"
require "selenium-webdriver"

require "crabfarm/version"
require "crabfarm/errors"
require "crabfarm/configuration"
require "crabfarm/global_state"
require "crabfarm/driver_bucket"
require "crabfarm/driver_bucket_pool"
require "crabfarm/http_client"
require "crabfarm/default_driver_factory"
require "crabfarm/phantom_driver_factory"
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
    # bundled browser dsl adapters
    register :browser_dsl, :surfer, 'Crabfarm::SurferBrowserDsl', 'crabfarm/adapters/browser/surfer'
    register :browser_dsl, :watir, 'Crabfarm::WatirBrowserDsl', 'crabfarm/adapters/browser/watir', ['watir-webdriver']
    register :browser_dsl, :capybara, 'Crabfarm::CapybaraBrowserDsl', 'crabfarm/adapters/browser/capybara', ['capybara']

    # bundled parsers dsl adapters
    register :parser_engine, :nokogiri, 'Crabfarm::NokogiriAdapter', 'crabfarm/adapters/parser/nokogiri'
    register :parser_engine, :pdf_reader, 'Crabfarm::PdfReaderAdapter', 'crabfarm/adapters/parser/pdf_reader', ['pdf-reader']

    # bundled state output builders
    register :output_builder, :hash, 'Crabfarm::HashOutputBuilder', 'crabfarm/adapters/output/hash'
    register :output_builder, :ostruct, 'Crabfarm::OStructOutputBuilder', 'crabfarm/adapters/output/ostruct'
    register :output_builder, :jbuilder, 'Crabfarm::JbuilderOutputBuilder', 'crabfarm/adapters/output/jbuilder', ['jbuilder']
  end
end
