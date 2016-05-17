require 'crabfarm/adapters/browser/base'
require 'crabfarm/utils/webdriver'

module Crabfarm
  module Live
    class Context < Crabfarm::Context

      def initialize(_manager)
        super()
        @manager = _manager
      end

      def proxy
        # override proxy so every context service points to crabtrap
        "127.0.0.1:#{@manager.proxy_port}"
      end

      def proxy_auth
        nil
      end

    private

      def build_browser_adapter(_proxy, _proxy_auth)
        # use a special browser adapter to override primary driver
        return BrowserAdapter.new @manager
      end

      class BrowserAdapter < Crabfarm::Adapters::Browser::Base

        def initialize(_manager)
          @manager = _manager
        end

        def build_driver(_session_id)
          if _session_id == :default_driver
            @manager.primary_driver
          else
            @manager.browser_adapter.build_driver _session_id
          end
        end

        def release_driver(_driver)
          if _driver != @manager.primary_driver
            @manager.browser_adapter.release_driver _driver
          end
          nil
        end

      end

    end
  end
end
