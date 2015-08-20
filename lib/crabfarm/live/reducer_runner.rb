require 'crabfarm/live/reducer_runner_direct'
require 'crabfarm/live/reducer_runner_rspec'

module Crabfarm
  module Live
    class ReducerRunner

      def initialize(_manager, _target)
        @manager = _manager
        @target = _target
        @rspec = true
        @params = {}
      end

      def dsl
        @dsl ||= Dsl.new self
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

      def execute
        strategy = if @rspec
          ReducerRunnerRSpec.new @manager, @target
        else
          ReducerRunnerDirect.new @manager, snapshot, @target, @params
        end

        begin
          Factories::SnapshotReducer.with_decorator reducer_decorator do
            strategy.execute
          end

          @manager.show_file reducer_decorator.last_path
          strategy.show_results
        rescue Crabfarm::LiveInterrupted
          Utils::Console.info "Execution interrupted"
        end
      end

    private

      def reducer_decorator
        @decorator ||= DisplayFileDecorator.new @manager
      end

      def snapshot
        if @snapshot.nil? then snapshot_for(@target) else @snapshot end
      end

      class Dsl
        extend Forwardable

        def initialize(_runner)
          @runner = _runner
        end

        def_delegators :@runner, :use_snapshot, :use_params, :clear_params, :use_rspec
      end

      class DisplayFileDecorator

        attr_reader :last_path

        def initialize(_manager)
          @manager = _manager
        end

        def prepare(_class, _path, _params)
          @last_path = _path
          nil
        end

      end

    end
  end
end