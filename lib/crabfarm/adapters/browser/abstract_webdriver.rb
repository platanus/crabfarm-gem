module Crabfarm
  module Adapters
    module Browser
      class AbstractWebdriver

        attr_accessor :config, :viewer

        def initialize(_proxy=nil, _viewer=nil)
          @config = load_driver_config
          @config[:proxy] = _proxy
          @viewer = _viewer
        end

        def prepare_driver_services
          start_server if viewer.nil?
        end

        def cleanup_driver_services
          stop_server if viewer.nil?
        end

        def build_driver(_session_id)
          wrap_driver(if viewer.nil?
            build_webdriver_instance
          else
            viewer.attach _session_id == :default_driver
          end)
        end

        def release_driver(_session_id, _wrapped)
          if viewer.nil?
            _wrapped.driver.quit rescue nil
          else
            viewer.detach _wrapped.driver
          end
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

        def start_server
          # Nothing by default
        end

        def stop_server
          # Nothing by default
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
