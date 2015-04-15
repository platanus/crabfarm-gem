module Crabfarm
  module Adapters
    module Browser
      class AbstractWebdriver

        attr_accessor :config

        def initialize(_proxy=nil)
          @config = load_driver_config
          @config[:proxy] = _proxy
        end

        def prepare_driver_services
          # Nothing by default
        end

        def cleanup_driver_services
          # Nothing by default
        end

        def build_driver(_session_id)
          return wrap_driver build_webdriver_instance
        end

        def release_driver(_driver)
          @driver.quit rescue nil
        end

      private

        def wrap_driver _driver
          if config[:dsl].present?
            Strategies.load(:webdriver_dsl, config[:dsl]).wrap _driver
          else _driver end
        end

        def build_webdriver_instance
          raise NotImplementedError.new
        end

        def load_driver_config
          {
            capabilities: Crabfarm.config.webdriver_capabilities,
            remote_host: Crabfarm.config.webdriver_remote_host,
            remote_timeout: Crabfarm.config.webdriver_remote_timeout,
            window_width: Crabfarm.config.webdriver_window_width,
            window_height: Crabfarm.config.webdriver_window_height,
            dsl: Crabfarm.config.webdriver_dsl
          }
        end

      end
    end
  end
end
