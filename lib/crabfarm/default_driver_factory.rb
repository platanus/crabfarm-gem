module Crabfarm
  class DefaultDriverFactory

    def initialize(_config={})
      @config = _config
    end

    def build_driver(_session_id)

      raise ConfigurationError.new 'must provide a webdriver type' unless config_present? :name
      driver_name = @config[:name].to_sym

      driver = case driver_name
      when :noop
        require "crabfarm/mocks/noop_driver"
        driver = Crabfarm::Mocks::NoopDriver.new # TODO: improve dummy driver...
      when :remote
        load_remote_driver
      when :firefox
        load_firefox_driver
      when :chrome
        load_chrome_driver
      else
        load_other_driver driver_name
      end

      # apply browser configuration to new driver
      driver.manage.window.resize_to(@config[:window_width], @config[:window_height]) rescue nil

      return driver
    end

    def load_remote_driver
      client = Selenium::WebDriver::Remote::Http::Default.new
      client.timeout = @config[:remote_timeout]

      if config_present? :proxy
        client.proxy = Selenium::WebDriver::Proxy.new({
          :http => @config[:proxy],
          :ssl => @config[:proxy]
        })
      end

      Selenium::WebDriver.for(:remote, {
        :url => @config[:remote_host],
        :http_client => client,
        :desired_capabilities => @config[:capabilities]
      })
    end

    def load_firefox_driver
      profile = Selenium::WebDriver::Firefox::Profile.new

      if config_present? :proxy
        profile.proxy = Selenium::WebDriver::Proxy.new({
          :http => @config[:proxy],
          :ssl => @config[:proxy]
        })
      end

      Selenium::WebDriver.for :firefox, :profile => profile
    end

    def load_chrome_driver
      switches = []

      if config_present? :proxy
        switches << "--proxy-server=#{@config[:proxy]}"
        switches << "--ignore-certificate-errors"
      end

      Selenium::WebDriver.for :chrome, :switches => switches
    end

    def load_other_driver(_name)
      raise ConfigurationError.new 'default driver does not support proxy' if config_present? :proxy

      Selenium::WebDriver.for _name.to_sym
    end

    def config_present?(_key)
      not (@config[_key].nil? or @config[_key].empty?)
    end

  end
end
