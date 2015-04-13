require "crabfarm/adapters/drivers/abstract_webdriver"

module Crabfarm
  module Adapters
    module Drivers
      class Firefox < AbstractWebdriver

      private

        def build_webdriver_instance
          profile = Selenium::WebDriver::Firefox::Profile.new

          if config.key? :proxy
            profile.proxy = Selenium::WebDriver::Proxy.new({
              :http => config[:proxy],
              :ssl => config[:proxy]
            })
          end

          Selenium::WebDriver.for :firefox, :profile => profile
        end

      end
    end
  end
end
