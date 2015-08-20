require 'crabfarm/support/webdriver_factory'
require "crabfarm/adapters/browser/abstract_webdriver"

module Crabfarm
  module Adapters
    module Browser
      class Firefox < AbstractWebdriver

        def headless?
          false
        end

      private

        def build_webdriver_instance
          Support::WebdriverFactory.build_firefox_driver config
        end

      end
    end
  end
end
