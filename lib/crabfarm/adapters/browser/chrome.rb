require "crabfarm/adapters/browser/abstract_webdriver"

module Crabfarm
  module Adapters
    module Browser
      class Chrome < AbstractWebdriver

      private

        def build_webdriver_instance
          switches = []

          if config[:proxy].present?
            switches << "--proxy-server=#{config[:proxy]}"
            switches << "--ignore-certificate-errors"
          end

          Selenium::WebDriver.for :chrome, :switches => switches
        end

      end
    end
  end
end