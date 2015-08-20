require 'crabfarm/support/webdriver_factory'
require 'crabfarm/support/phantom_runner'
require 'crabfarm/adapters/browser/abstract_webdriver'

module Crabfarm
  module Adapters
    module Browser
      class PhantomJs < AbstractWebdriver

        def prepare_driver_services
          @phantom = load_and_start_phantom if @phantom.nil?
        end

        def cleanup_driver_services
          @phantom.stop unless @phantom.nil?
          @phantom = nil
        end

      private

        def build_webdriver_instance
          Support::WebdriverFactory.build_remote_driver driver_config
        end

        def load_and_start_phantom
          new_phantom = Support::PhantomRunner.new phantom_config
          new_phantom.start
          return new_phantom
        end

        def phantom_config
          {
            load_images: Crabfarm.config.phantom_load_images,
            ssl: Crabfarm.config.phantom_ssl,
            bin_path: Crabfarm.config.phantom_bin_path,
            proxy: config[:proxy],
            port: Utils::PortDiscovery.find_available_port
          }
        end

        def phantom_url
          "http://localhost:#{@phantom.port}"
        end

        def driver_config
          config.merge({
            remote_host: phantom_url,
            proxy: nil
          })
        end

      end
    end
  end
end
