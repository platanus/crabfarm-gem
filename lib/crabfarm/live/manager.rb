require 'crabfarm/support/webdriver_factory'
require 'crabfarm/crabtrap_runner'

module Crabfarm
  module Live
    class Manager

      def initialize
        @port = Utils::PortDiscovery.find_available_port
        @driver = Crabfarm.config.recorder_driver
      end

      def proxy_port
        @port
      end

      def start
        load_primary_driver
      end

      def stop
        stop_crabtrap
        release_primary_driver
      end

      def primary_driver
        @driver
      end

      def generate_support_driver
        # TODO: improve on this mechanics, maybe use a frame in the same driver for this
        build_driver
      end

      def start_crabtrap(_mode, _memento_path=nil)
        if @crabtrap.nil?
          options = {
            mode: _mode,
            bucket_path: _memento_path,
            port: @port
          }

          @crabtrap = CrabtrapRunner.new config.crabtrap_config.merge(options)
          @crabtrap.start
        end
      end

      def stop_crabtrap
        unless @crabtrap.nil?
          @crabtrap.kill
          @crabtrap = nil
        else nil end
      end

    private

      def load_primary_driver
        @driver = build_driver
      end

      def release_primary_driver
        @driver.quit rescue nil unless @driver.nil?
      end

      def build_driver
        case @driver
        when :firefox
          Crabfarm::Support::WebdriverFactory.build_firefox_driver driver_config
        when :chrome
          Crabfarm::Support::WebdriverFactory.build_chrome_driver driver_config
        else return nil end
      end

      def driver_config
        {
          proxy: "127.0.0.1:#{@port}"
        }
      end

      def config
        Crabfarm.config
      end

    end
  end
end