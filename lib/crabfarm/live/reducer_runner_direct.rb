require 'benchmark'
require 'crabfarm/utils/console'

module Crabfarm
  module Live
    class ReducerRunnerDirect

      def initialize(_manager, _snapshot, _target, _params)
        @manager = _manager
        @snapshot = _snapshot
        @target = _target
        @params = _params
      end

      def execute
        raise ArgumentError.new 'Must provide a snapshot to execute reducer' if @snapshot.nil?

        snapshot_path = @target.snapshot_path @snapshot
        raise ArgumentError.new "Snapshot does not exist #{snapshot_path}" unless File.exist? snapshot_path

        @reducer = Factories::SnapshotReducer.build @target, snapshot_path, (@params || {})
        @elapsed = Benchmark.measure { @reducer.run }
      end

      def show_results
        @manager.show_message(
          :neutral,
          'Reducing completed!',
          "The page was parsed in #{@elapsed.real} seconds",
          @reducer.to_json,
          :json
        )

        Utils::Console.json_result @reducer
        Utils::Console.info "Completed in #{@elapsed.real} s"
      end

    end
  end
end