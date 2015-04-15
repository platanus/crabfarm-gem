require 'crabfarm/support/webdriver_factory'
require "crabfarm/adapters/browser/abstract_webdriver"

module Crabfarm
  module Adapters
    module Browser
      class Chrome < AbstractWebdriver

      private

        def build_webdriver_instance
          Support::WebdriverFactory.build_chrome_driver config
        end

      end
    end
  end
end
