require 'timeout'
require 'crabfarm/utils/console'
require 'crabfarm/utils/webdriver'
require 'crabfarm/support/webdriver_factory'
require 'crabfarm/crabtrap_runner'

module Crabfarm
  module Live
    class Manager

      INJECTION_TM = 5 # seconds

      def initialize
        @port = Utils::PortDiscovery.find_available_port
        @driver_name = Crabfarm.config.recorder_driver
      end

      def proxy_port
        @port
      end

      def start
        set_memento
        load_primary_driver
      end

      def stop
        stop_crabtrap
        release_primary_driver
      end

      def primary_driver
        @driver
      end

      def reset_driver_status
        # TODO: manage driver handles and recreate driver if needed
        primary_driver.get('https://www.crabtrap.io/instructions.html')
      end

      def block_requests
        begin
          stop_crabtrap
          return yield
        ensure
          set_memento nil
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

      def inject_web_tools
        Utils::Console.trap_errors 'injecting web tools' do
          Utils::Webdriver.inject_style primary_driver, 'https://www.crabtrap.io/selectorgadget_combined.css'
          Utils::Webdriver.inject_style primary_driver, 'https://www.crabtrap.io/tools.css'
          Utils::Webdriver.inject_script primary_driver, 'https://www.crabtrap.io/selectorgadget_combined.js'
          Utils::Webdriver.inject_script primary_driver, 'https://www.crabtrap.io/tools.js'
          Timeout::timeout(INJECTION_TM) { wait_for_injection }
        end
      end

      def show_dialog(_status, _title, _subtitle, _content=nil, _content_type=:text)
        Utils::Console.trap_errors 'loading web dialog' do
          primary_driver.execute_script(
            "window.crabfarm.showDialog.apply(null, arguments);",
            _status.to_s,
            _title,
            _subtitle,
            _content,
            _content_type.to_s
          );
        end
      end

      def show_selector_gadget()
        Utils::Console.trap_errors 'loading selector gadget' do
          primary_driver.execute_script(
            'window.crabfarm.showSelectorGadget();'
          )
        end
      end

      # Viewer implementation

      def attach(_primary=true)
        if _primary then primary_driver else build_driver end
      end

      def detach(_driver)
        if _driver != primary_driver
          _driver.quit rescue nil
        end
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

      def wait_for_injection
        while primary_driver.execute_script "return (typeof window.crabfarm === 'undefined');"
          sleep 1.0
        end
      end

    end
  end
end