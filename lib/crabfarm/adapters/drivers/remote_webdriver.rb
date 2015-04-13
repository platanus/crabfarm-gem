require "crabfarm/adapters/drivers/abstract_webdriver"

module Crabfarm
  module Adapters
    module Drivers
      class RemoteWebdriver < AbstractWebdriver

      private

        def build_webdriver_instance
          client = Selenium::WebDriver::Remote::Http::Default.new
          client.timeout = config[:remote_timeout]

          if config.has_key? :proxy
            client.proxy = Selenium::WebDriver::Proxy.new({
              :http => config[:proxy],
              :ssl => config[:proxy]
            })
          end

          Selenium::WebDriver.for(:remote, {
            :url => config[:remote_host],
            :http_client => client,
            :desired_capabilities => config[:capabilities] || Selenium::WebDriver::Remote::Capabilities.firefox
          })
        end

      end
    end
  end
end
