module Crabfarm
  class DefaultDriverFactory

    def initialize(_config={})
      @config = _config
    end

    def build_driver(_session_id)

      driver_name = @config[:name]
      raise ConfigurationError.new 'must provide a webdriver type' if driver_name.nil?

      case driver_name
      when :noop
        require "crabfarm/mocks/noop_driver"
        driver = Crabfarm::Mocks::NoopDriver.new # TODO: improve dummy driver...
      when :remote
        # setup a custom client to use longer timeouts
        client = Selenium::WebDriver::Remote::Http::Default.new
        client.timeout = @config[:remote_timeout]

        driver = Selenium::WebDriver.for :remote, {
          :url => @config[:remote_host],
          :http_client => client,
          :desired_capabilities => @config[:capabilities]
        }

        driver.send(:bridge).setWindowSize(@config[:window_width], @config[:window_height])
      else
        driver = Selenium::WebDriver.for driver_name.to_sym

        # apply browser configuration to new driver
        driver.manage.window.resize_to(@config[:window_width], @config[:window_height]) rescue nil
      end

      return driver
    end

  end
end
