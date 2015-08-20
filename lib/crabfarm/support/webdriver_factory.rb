require 'selenium-webdriver'

module Crabfarm
 module Support
  module WebdriverFactory
    extend self

    def build_chrome_driver(_options={})
      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome

      if _options[:proxy].present?
        capabilities.proxy = Selenium::WebDriver::Proxy.new({
          :http => _options[:proxy],
          :ssl => _options[:proxy]
        })
      end

      common_setup Selenium::WebDriver.for(:chrome, detach: false, desired_capabilities: capabilities), _options
    end

    def build_firefox_driver(_options={})
      capabilities = Selenium::WebDriver::Remote::Capabilities.firefox

      if _options[:proxy].present?
        capabilities.proxy = Selenium::WebDriver::Proxy.new({
          :http => _options[:proxy],
          :ssl => _options[:proxy]
        })
      end

      common_setup Selenium::WebDriver.for(:firefox, desired_capabilities: capabilities), _options
    end

    def build_remote_driver(_options={})
      client = Selenium::WebDriver::Remote::Http::Default.new
      client.timeout = _options[:remote_timeout]

      if _options[:proxy].present?
        client.proxy = Selenium::WebDriver::Proxy.new({
          :http => _options[:proxy],
          :ssl => _options[:proxy]
        })
      end

      common_setup(Selenium::WebDriver.for(:remote, {
        :url => _options[:remote_host],
        :http_client => client,
        :desired_capabilities => _options[:capabilities] || Selenium::WebDriver::Remote::Capabilities.firefox
      }), _options)
    end

  private

    def common_setup(_driver, _options)
      _driver.manage.window.resize_to(_options[:window_width], _options[:window_height]) rescue nil
      return _driver
    end

  end
 end
end