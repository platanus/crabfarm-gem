require 'crabfarm/utils/console'
require 'crabfarm/utils/webdriver'

module Crabfarm
  module Live
    class Viewer

      INJECTION_TM = 5 # seconds

      attr_reader :driver

      def initialize(_driver)
        @driver = _driver
        @injected = false
      end

      def welcome
        @injected = false
        driver.get 'https://www.crabtrap.io/welcome.html'
      end

      def reset
        driver.get 'https://www.crabtrap.io/instructions.html'
        @injected = false
      end

      def show_file(_path)
        driver.get "file://#{_path}"
      end

      def show_message(_status, _title, _subtitle, _content=nil, _content_type=:text)
        inject_web_tools
        Utils::Console.trap_errors 'loading web dialog' do
          driver.execute_script(
            "window.crabfarm.showDialog.apply(null, arguments);",
            _status.to_s,
            _title,
            _subtitle,
            _content,
            _content_type.to_s
          );
        end
      end

      def show_selector_gadget
        inject_web_tools
        Utils::Console.trap_errors 'loading selector gadget' do
          driver.execute_script(
            'window.crabfarm.showSelectorGadget();'
          )
        end
      end

    private

      def inject_web_tools
        return if @injecting

        Utils::Console.trap_errors 'injecting web tools' do
          Utils::Webdriver.inject_style driver, 'https://www.crabtrap.io/selectorgadget_combined.css'
          Utils::Webdriver.inject_style driver, 'https://www.crabtrap.io/tools.css'
          Utils::Webdriver.inject_script driver, 'https://www.crabtrap.io/selectorgadget_combined.js'
          Utils::Webdriver.inject_script driver, 'https://www.crabtrap.io/tools.js'
          Timeout::timeout(INJECTION_TM) { wait_for_injection }
        end

        @injected = true
      end

      def wait_for_injection
        while driver.execute_script "return (typeof window.crabfarm === 'undefined');"
          sleep 1.0
        end
      end

    end
  end
end