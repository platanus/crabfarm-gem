require "logger"
require "forwardable"
require "active_support/inflector"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/numeric/time"

require "crabfarm/version"
require "crabfarm/errors"
require "crabfarm/configuration"
require "crabfarm/driver_pool"
require "crabfarm/state_store"
require "crabfarm/context"
require "crabfarm/transition_service"
require "crabfarm/base_navigator"
require "crabfarm/base_reducer"
require "crabfarm/base_struct"
require "crabfarm/strategies"

require "crabfarm/factories/context"
require "crabfarm/factories/navigator"
require "crabfarm/factories/reducer"
require "crabfarm/factories/snapshot_reducer"

require "crabfarm/utils/port_discovery"
require "crabfarm/utils/naming"
require "crabfarm/utils/resolve"

module Crabfarm

  @@config = Configuration.new
  @@logger = nil
  @@live = nil
  @@debug = false

  def self.root
    File.dirname __dir__
  end

  def self.inside_crawler_app?
    defined? CF_PATH
  end

  def self.app_path
    CF_PATH
  end

  def self.config
    @@config
  end

  def self.logger
    if @@logger.nil?
      if @@config.log_path.nil? or @@config.log_path.empty?
        @@logger = Logger.new STDOUT
      else
        @@logger = Logger.new File.join(@@config.log_path, 'crawler.log')
      end
    end

    @@logger
  end

  def self.read_crabfile(_path)
    @@config.instance_eval File.read _path
  end

  def self.install_live_backend!
    require "crabfarm/live/manager"
    @@live = Live::Manager.new
  end

  def self.live
    @@live
  end

  def self.live?
    not @@live.nil?
  end

  def self.enable_debugging!
    require 'pry-byebug'
    @@debug = true
  end

  def self.debug?
    @@debug
  end

  def self.with_context(_memento=nil)
    ctx = Factories::Context.build _memento
    begin
      ctx.prepare
      yield ctx
    ensure
      ctx.release
    end
  end

  module Strategies
    # bundled browser adapters
    register :browser, :phantomjs, 'Crabfarm::Adapters::Browser::PhantomJs', dependencies: ['selenium-webdriver']
    register :browser, :firefox, 'Crabfarm::Adapters::Browser::Firefox', dependencies: ['selenium-webdriver']
    register :browser, :chrome, 'Crabfarm::Adapters::Browser::Chrome', dependencies: ['selenium-webdriver']
    register :browser, :remote, 'Crabfarm::Adapters::Browser::RemoteWebdriver', dependencies: ['selenium-webdriver']
    register :browser, :chenso, 'Crabfarm::Adapters::Browser::Chenso', dependencies: ['pincers']
    register :browser, :noop, 'Crabfarm::Adapters::Browser::Noop'

    # bundled webdriver dsl adapters
    register :webdriver_dsl, :pincers, 'Crabfarm::Adapters::DriverWrapper::Pincers', dependencies: ['pincers']
    register :webdriver_dsl, :watir, 'Crabfarm::Adapters::DriverWrapper::Watir', dependencies: ['watir-webdriver']
    register :webdriver_dsl, :capybara, 'Crabfarm::Adapters::DriverWrapper::Capybara', dependencies: ['capybara']

    # bundled parsers dsl adapters
    register :parser, :pincers, 'Crabfarm::Adapters::Parser::Pincers', dependencies: ['pincers', 'nokogiri']
    register :parser, :nokogiri, 'Crabfarm::Adapters::Parser::Nokogiri', dependencies: ['nokogiri']
    register :parser, :pdf_reader, 'Crabfarm::Adapters::Parser::PdfReader', dependencies: ['pdf-reader']
  end
end
