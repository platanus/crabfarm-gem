require 'benchmark'
require 'crabfarm/utils/console'
require 'crabfarm/live/context'

module Crabfarm
  module Live
    class NavigatorRunner

      class Dsl
        extend Forwardable

        def initialize(_runner)
          @runner = _runner
        end

        def_delegators :@runner, :use_memento, :use_params, :clear_params, :navigate_to
      end

      def initialize(_manager, _target)
        @manager = _manager
        @target = _target
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
      end

      def use_params(_params={})
        @params = @params.merge _params
      end

      def clear_params
        @params = {}
      end

      def navigate_to(_navigator, _params={})
        # TODO.
      end

      def prepare(_memento) # decorator
        @manager.set_memento _memento
        Context.new @manager
      end

      def execute
        Factories::Context.with_decorator self do
          Crabfarm.with_context memento do |ctx|
            @elapsed = Benchmark.measure do
              @transition = TransitionService.transition ctx, @target, @params
            end
          end
        end

        show_result
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