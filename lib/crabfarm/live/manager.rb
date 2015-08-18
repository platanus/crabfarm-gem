require 'timeout'
require 'tempfile'
require 'crabfarm/live/viewer'
require 'crabfarm/support/webdriver_factory'
require 'crabfarm/crabtrap_runner'

module Crabfarm
  module Live
    class Manager
      extend Forwardable

      attr_reader :primary_driver, :browser_adapter, :proxy_port

      def_delegators :@viewer, :show_file, :show_message

      def initialize
        @proxy_port = Utils::PortDiscovery.find_available_port
      end

      def start
        set_memento
        load_browser_adapter
        load_primary_driver_and_viewer
        @viewer.welcome
      end

      def stop
        release_primary_driver
        release_viewer_driver
        stop_crabtrap
      end

      def reset
        reset_primary_driver
        @viewer.reset
      end

      def block_requests
        begin
          stop_crabtrap
          return yield
        ensure
          set_memento nil
        end
      end

      def show_primary_contents
        unless @viewer_driver.nil?
          temp_file = dump_to_temp_file primary_driver
          begin
            show_file temp_file.path # block requests? not sure
          ensure
            temp_file.unlink
          end
        end
      end

      def set_memento(_memento=nil)
        options = if _memento
          path = Utils::Resolve.memento_path _memento
          raise ConfigurationError.new "No memento found at #{path}" unless File.exists? path
          { mode: :replay, bucket_path: path }
        else
          { mode: :pass }
        end

        stop_crabtrap
        start_crabtrap options
      end

    private

      def load_browser_adapter
        @browser_adapter = Strategies.load(:browser, config.browser).new crabtrap_address
        @browser_adapter.prepare_driver_services
      end

      def load_primary_driver_and_viewer
        @primary_driver = browser_adapter.build_driver :default_driver

        # IDEA: improve this to allow different viewer modes
        unless browser_adapter.headless?
          primary_webdriver = browser_adapter.extract_webdriver @primary_driver
          @viewer = Viewer.new primary_webdriver unless primary_webdriver.nil?
        end

        if @viewer.nil?
          @viewer_driver = build_support_driver
          @viewer = Viewer.new @viewer_driver
        end
      end

      def build_support_driver
        case config.recorder_driver
        when :firefox
          Crabfarm::Support::WebdriverFactory.build_firefox_driver driver_config
        when :chrome
          Crabfarm::Support::WebdriverFactory.build_chrome_driver driver_config
        else return nil end
      end

      def reset_primary_driver
        @browser_adapter.reset_driver @primary_driver
      end

      def start_crabtrap(_options)
        _options = _options.merge({
          port: @proxy_port,
          virtual: File.expand_path('./assets/live-tools', Crabfarm.root)
        })

        @crabtrap = CrabtrapRunner.new config.crabtrap_config.merge(_options)
        @crabtrap.start
      end

      def stop_crabtrap
        unless @crabtrap.nil?
          @crabtrap.kill
          @crabtrap = nil
        else nil end
      end

      def release_primary_driver
        @browser_adapter.release_driver @primary_driver
        @browser_adapter.cleanup_driver_services
        @primary_driver = nil
      end

      def release_viewer_driver
        unless @viewer_driver.nil?
          @viewer_driver.quit rescue nil
          @viewer_driver = nil
          @viewer = nil
        end
      end

      def dump_to_temp_file(_browser)
        temp = Tempfile.new 'cb_live'
        temp.write _browser.to_html
        temp.close
        temp
      end

      def driver_config
        {
          proxy: crabtrap_address
        }
      end

      def crabtrap_address
        "127.0.0.1:#{@proxy_port}"
      end

      def config
        Crabfarm.config
      end

    end
  end
end