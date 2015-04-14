require "crabfarm/adapters/browser/abstract_webdriver"
require "crabfarm/phantom_runner"

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
          client = Selenium::WebDriver::Remote::Http::Default.new
          client.timeout = config[:remote_timeout]

          driver = Selenium::WebDriver.for :remote, {
            :url => phantom_url,
            :http_client => client,
            :desired_capabilities => config[:capabilities] || Selenium::WebDriver::Remote::Capabilities.firefox
          }

          # TODO: not sure if this is necessary...
          # driver.send(:bridge).setWindowSize(config[:window_width], config[:window_height])

          return driver
        end

        def load_and_start_phantom
          new_phantom = PhantomRunner.new phantom_config
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

      end
    end
  end
end
