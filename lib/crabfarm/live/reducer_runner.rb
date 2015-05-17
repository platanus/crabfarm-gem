require 'crabfarm/live/reducer_runner_direct'
require 'crabfarm/live/reducer_runner_rspec'

module Crabfarm
  module Live
    class ReducerRunner

      class Dsl
        extend Forwardable

        def initialize(_runner)
          @runner = _runner
        end

        def_delegators :@runner, :use_snapshot, :use_params, :clear_params, :use_rspec
      end

      def initialize(_manager, _target)
        @manager = _manager
        @target = _target
        @rspec = true
        @params = {}
      end

      def dsl
        @dsl ||= Dsl.new self
      end

      def snapshot
        if @snapshot.nil? then snapshot_for(@target) else @snapshot end
      end

      def use_snapshot(_snapshot)
        @snapshot = _snapshot
        @rspec = false
      end

      def use_params(_params={})
        @params = @params.merge _params
        @rspec = false
      end

      def clear_params
        @params = {}
        @rspec = false
      end

      def use_rspec
        @rspec = true
      end

      def prepare(_class, _path, _params) # decorator
        @manager.primary_driver.get("file://#{_path}")
        nil
      end

      def execute
        strategy = if @rspec
          ReducerRunnerRSpec.new @manager, @target
        else
          ReducerRunnerDirect.new @manager, snapshot, @target, @params
        end

        Factories::SnapshotReducer.with_decorator self do
          @manager.block_requests { strategy.execute }
        end

        strategy.show_results
      end

    end
  end
end