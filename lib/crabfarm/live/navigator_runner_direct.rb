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
          @transition = TransitionService.transition ctx, @target, (@params || {})
        end
      end

      def show_results
        @manager.show_message(
          :neutral,
          'Navigation completed!',
          "The page was scrapped in #{@transition.elapsed} seconds",
          @transition.document.to_json,
          :json
        )

        Utils::Console.json_result @transition.document
        Utils::Console.info "Completed in #{@elapsed.real} s"
      end

    end
  end
end