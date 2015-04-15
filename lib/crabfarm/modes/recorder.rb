require 'rainbow'
require 'rainbow/ext/string'
require 'crabfarm/crabtrap_runner'

module Crabfarm
  module Modes
    module Recorder

      def self.memento_path(_name)
        File.join(GlobalState.mementos_path, _name + '.json.gz')
      end

      def self.start(_target, _replay=false)
        return puts "Must provide a recording target" unless _target.is_a? String

        target_path = memento_path _target
        return puts "Memento file does not exist: #{target_path}" if _replay and not File.exist? target_path

        crabtrap_config = Crabfarm.config.crabtrap_config
        crabtrap_config[:mode] = _replay ? :replay : :capture
        crabtrap_config[:port] = Utils::PortDiscovery.find_available_port
        crabtrap_config[:bucket_path] = target_path

        crabtrap = CrabtrapRunner.new crabtrap_config
        crabtrap.start

        begin
          browser_name = Crabfarm.config.recorder_driver
          browser_factory = Strategies.load(:browser, browser_name).new "127.0.0.1:#{crabtrap.port}"
          driver = browser_factory.build_driver nil

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

    end
  end
end
