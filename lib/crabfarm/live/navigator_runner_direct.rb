require 'benchmark'
require 'crabfarm/utils/console'

module Crabfarm
  module Live
    class NavigatorRunnerDirect

      def initialize(_manager, _memento, _target, _params)
        @manager = _manager
        @memento = _memento
        @target = _target
        @params = _params
      end

      def execute
        Crabfarm.with_context @memento do |ctx|
          @elapsed = Benchmark.measure do
            @transition = TransitionService.transition ctx, @target, (@params || {})
          end
        end
      end

      def show_results
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