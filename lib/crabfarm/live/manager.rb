require 'crabfarm/support/webdriver_factory'
require 'crabfarm/crabtrap_runner'

module Crabfarm
  module Live
    class Manager

      def initialize
        @port = Utils::PortDiscovery.find_available_port
        @driver_name = Crabfarm.config.recorder_driver
      end

      def proxy_port
        @port
      end

      def start
        reset
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

      def reset(_memento=nil)

        reset_drivers

        options = if _memento
          path = memento_path _memento
          raise ConfigurationError.new "No memento found at #{path}" unless File.exists? path
          { mode: :replay, bucket_path: path }
        else
          { mode: :pass }
        end

        options.merge!({
          port: @port,
          virtual: File.expand_path('./assets/live-tools', Crabfarm.root)
        })

        stop_crabtrap
        @crabtrap = CrabtrapRunner.new config.crabtrap_config.merge(options)
        @crabtrap.start

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
        @driver.get('https://www.crabtrap.io/welcome.html')
      end

      def release_primary_driver
        unless @driver.nil?
          @driver.quit rescue nil
          @driver = nil
        end
      end

      def reset_drivers
        unless @driver.nil?
          # TODO: manage window handles
          @driver.get('https://www.crabtrap.io/instructions.html')
        end
      end

      def build_driver
        case @driver_name
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

      def memento_path(_name)
        File.join(GlobalState.mementos_path, _name.to_s + '.json.gz')
      end

    end
  end
end