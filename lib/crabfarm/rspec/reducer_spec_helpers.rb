module Crabfarm
  module RSpec
    module ReducerSpecHelpers

      def reduce(_snapshot, _params={})
        ensure_reducer_for :reduce
        raise ArgumentError.new 'Must provide a snapshot for reducer specs' if _snapshot.nil?

        snap_path = described_class.snapshot_path _snapshot
        raise ArgumentError.new "Snapshot does not exist #{snap_path}" unless File.exist? snap_path

        reducer = Factories::SnapshotReducer.build described_class, snap_path, (_params || {})
        reducer.run
        reducer
      end

      def reducer
        @reducer_state ||= reduce @reducer_snapshot, @reducer_params
      end

    private

      def ensure_reducer_for(_name)
        raise "'#{_name}' is only available in reducer specs." unless described_class < Crabfarm::BaseReducer
      end

    end
  end
end