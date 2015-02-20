require 'rainbow'
require 'rainbow/ext/string'
require 'crabfarm/crabtrap_runner'

module Crabfarm
  module Modes
    class Recorder

      def self.start(_target)
        return puts "Must provide a recording name" unless _target.is_a? String

        crabtrap_config = Crabfarm.config.crabtrap_config
        crabtrap_config[:mode] = :capture
        crabtrap_config[:bucket_path] = File.join(CF_PATH, 'spec/mementos', _target + '.json.gz')

        crabtrap = CrabtrapRunner.new crabtrap_config
        crabtrap.start

        driver_config = Crabfarm.config.driver_config
        driver_config[:name] = :firefox
        driver_config[:proxy] = "127.0.0.1:#{crabtrap.port}"

        driver = DefaultDriverFactory.new(driver_config).build_driver nil

        begin
          puts "Press Ctrl-C to stop capturing."
          loop do
            driver.current_url
            sleep 1.0
          end
        rescue Selenium::WebDriver::Error::WebDriverError, SystemExit, Interrupt
          # noop
        end

        puts "Releasing crawling context".color(:green)
        driver.quit rescue nil
        crabtrap.stop
      end

    end
  end
end
