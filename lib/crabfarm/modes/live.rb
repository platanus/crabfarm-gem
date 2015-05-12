require 'crabfarm/live/watcher'
require 'crabfarm/live/controller'

module Crabfarm
  module Modes
    module Live
      extend self

      def start_watch
        begin
          Crabfarm.enable_debugging!
          Crabfarm.install_live_backend!
          Crabfarm.live.start

          controller = Crabfarm::Live::Controller.new Crabfarm.live
          watcher = Crabfarm::Live::Watcher.new controller
          watcher.watch 0.2

        rescue SystemExit, Interrupt
          # nothing
        rescue Exception => e
          puts "Fatal error: #{e.to_s}".color Console::Colors::ERROR
          puts e.backtrace
        ensure
          puts 'Exiting'
          Crabfarm.live.stop rescue nil
        end
      end

    end
  end
end
