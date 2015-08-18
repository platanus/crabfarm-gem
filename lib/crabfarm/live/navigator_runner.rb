require 'crabfarm/live/context'
require 'crabfarm/live/navigator_runner_direct'
require 'crabfarm/live/navigator_runner_rspec'

module Crabfarm
  module Live
    class NavigatorRunner

      def initialize(_manager, _target)
        @manager = _manager
        @target = _target
        @rspec = true
        @params = {}
      end

      def dsl
        @dsl ||= Dsl.new self
      end

      def use_memento(_memento)
        @memento = _memento
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
          NavigatorRunnerRSpec.new @manager, @target
        else
          NavigatorRunnerDirect.new @manager, memento, @target, @params
        end

        Factories::Context.with_decorator navigator_decorator do
          strategy.execute
        end

        @manager.show_primary_contents
        strategy.show_results
      end

    private

      def memento
        if @memento.nil? then memento_for(@target) else @memento end
      end

      def memento_for(_class)
        Utils::Naming.route_from_constant(_class.to_s).join File::SEPARATOR
      end

      def navigator_decorator
        @decorator ||= InterceptContextDecorator.new @manager
      end

      class InterceptContextDecorator

        def initialize(_manager)
          @manager = _manager
        end

        def prepare(_memento)
          @manager.restart_crabtrap _memento
          inject_managed_context
        end

        def inject_managed_context
          Context.new @manager
        end

      end

      class Dsl
        extend Forwardable

        def initialize(_runner)
          @runner = _runner
        end

        def_delegators :@runner, :use_memento, :use_params, :clear_params, :use_rspec, :navigate_to
      end

    end
  end
end