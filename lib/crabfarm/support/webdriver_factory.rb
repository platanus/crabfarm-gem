require 'selenium-webdriver'

module Crabfarm
  module Support
    module WebdriverFactory
      extend self

      def build_chrome_driver(_options={})
        capabilities = Selenium::WebDriver::Remote::Capabilities.chrome
        capabilities.proxy = build_proxy(_options) if _options[:proxy].present?

        setup_webdriver Selenium::WebDriver.for(:chrome, detach: false, desired_capabilities: capabilities), _options
      end

      def build_firefox_driver(_options={})
        capabilities = Selenium::WebDriver::Remote::Capabilities.firefox
        capabilities.proxy = build_proxy(_options) if _options[:proxy].present?

        setup_webdriver Selenium::WebDriver.for(:firefox, desired_capabilities: capabilities), _options
      end

      def build_remote_driver(_options={})
        client = Selenium::WebDriver::Remote::Http::Default.new
        client.timeout = _options[:remote_timeout]
        client.proxy = build_proxy(_options) if _options[:proxy].present?

        setup_webdriver(Selenium::WebDriver.for(:remote, {
          :url => _options[:remote_host],
          :http_client => client,
          :desired_capabilities => _options[:capabilities] || Selenium::WebDriver::Remote::Capabilities.firefox
        }), _options)
      end

    private

      def build_proxy(_options)
        # TODO: support authentication
        Selenium::WebDriver::Proxy.new({
          :http => _options[:proxy],
          :ssl => _options[:proxy]
        })
      end

      def setup_webdriver(_driver, _options)
        _driver.manage.window.resize_to(_options[:window_width], _options[:window_height]) rescue nil
        return _driver
      end
    end
  end
end