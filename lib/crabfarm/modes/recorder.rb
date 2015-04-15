require 'rainbow'
require 'rainbow/ext/string'
require 'crabfarm/support/webdriver_factory'
require 'crabfarm/crabtrap_runner'

module Crabfarm
  module Modes
    module Recorder
      extend self

      def memento_path(_name)
        File.join(GlobalState.mementos_path, _name + '.json.gz')
      end

      def start(_target, _replay=false)
        return puts "Must provide a recording target" unless _target.is_a? String

        target_path = memento_path _target
        return puts "Memento file does not exist: #{target_path}" if _replay and not File.exist? target_path

        start_crabtrap _replay, target_path

        begin
          driver = build_driver Crabfarm.config.recorder_driver
          return puts "Invalid recorder_driver name '#{Crabfarm.config.recorder_driver}'" if driver.nil?

          begin
            puts "Press Ctrl-C or close browser to stop #{_replay ? 'playback' : 'capturing'}."
            loop do
              driver.current_url
              sleep 1.0
            end
          rescue Exception => e
            # noop
          end

          puts "Releasing crawling context".color(:green)
          driver.quit rescue nil
        ensure
          crabtrap.stop
        end
      end

    private

      def start_crabtrap(_replay, _target_path)
        crabtrap_config = Crabfarm.config.crabtrap_config
        crabtrap_config[:mode] = _replay ? :replay : :capture
        crabtrap_config[:port] = Utils::PortDiscovery.find_available_port
        crabtrap_config[:bucket_path] = _target_path

        @crabtrap = CrabtrapRunner.new crabtrap_config
        @crabtrap.start
      end

      def crabtrap
        @crabtrap
      end

      def build_driver(_name)
        case _name.to_sym
        when :firefox
          Crabfarm::Support::WebdriverFactory.build_firefox_driver driver_config
        when :chrome
          Crabfarm::Support::WebdriverFactory.build_chrome_driver driver_config
        else return nil end
      end

      def driver_config
        {
          proxy: "127.0.0.1:#{crabtrap.port}",
          window_width: Crabfarm.config.webdriver_window_width,
          window_height: Crabfarm.config.webdriver_window_height
        }
      end



    end
  end
end
