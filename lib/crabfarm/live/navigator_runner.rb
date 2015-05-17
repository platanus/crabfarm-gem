require 'crabfarm/live/context'
require 'crabfarm/live/navigator_runner_direct'
require 'crabfarm/live/navigator_runner_rspec'

module Crabfarm
  module Live
    class NavigatorRunner

      class Dsl
        extend Forwardable

        def initialize(_runner)
          @runner = _runner
        end

        def_delegators :@runner, :use_memento, :use_params, :clear_params, :use_rspec, :navigate_to
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

      def memento
        if @memento.nil? then memento_for(@target) else @memento end
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

      def navigate_to(_navigator, _params={})
        # TODO.
      end

      def prepare(_memento) # decorator
        @manager.set_memento _memento
        Context.new @manager
      end

      def execute
        strategy = if @rspec
          NavigatorRunnerRSpec.new @manager, @target
        else
          NavigatorRunnerDirect.new @manager, memento, @target, @params
        end

        Factories::Context.with_decorator self do
          strategy.execute
        end

        strategy.show_results
      end

    private

      def memento_for(_class)
        Utils::Naming.route_from_constant(_class.to_s).join(File::SEPARATOR)
      end

      def show_result
        @manager.inject_web_tools
        @manager.show_dialog(
          :neutral,
          'Navigation completed!',
          "The page was scrapped in #{@elapsed.real} seconds",
          @transition.document.to_json,
          :json
        )

        Utils::Console.json_result @transition.document
        Utils::Console.info "Completed in #{@elapsed.real} s"
      end

    end
  end
end