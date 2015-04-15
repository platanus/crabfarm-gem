require 'crabfarm/support/webdriver_factory'
require "crabfarm/adapters/browser/abstract_webdriver"

module Crabfarm
  module Adapters
    module Browser
      class RemoteWebdriver < AbstractWebdriver

      private

        def build_webdriver_instance
          WebdriverFactory.build_remote_driver config
        end

      end
    end
  end
end
