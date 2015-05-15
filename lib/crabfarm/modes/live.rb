require 'crabfarm/live/watcher'
require 'crabfarm/live/controller'
require 'crabfarm/utils/console'

module Crabfarm
  module Modes
    module Live
      extend self

      def start_watch
        Utils::Console.system 'Starting crabfarm live'

        begin
          Crabfarm.enable_debugging!
          Crabfarm.install_live_backend!
          Crabfarm.live.start

          controller = Crabfarm::Live::Controller.new Crabfarm.live
          watcher = Crabfarm::Live::Watcher.new controller
          watcher.watch 0.2

        rescue SystemExit, Interrupt
          # nothing
        rescue Exception => exc
          Utils::Console.error "Fatal error!"
          Utils::Console.exception exc
        ensure
          Utils::Console.system 'Exiting'
          Crabfarm.live.stop rescue nil
        end
      end

    end
  end
end
