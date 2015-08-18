require 'crabfarm/utils/console'
require 'crabfarm/live/navigator_runner'
require 'crabfarm/live/reducer_runner'

module Crabfarm
  module Live
    class Controller

      def initialize(_manager)
        @manager = _manager
      end

      def display_external_error(_exc)
        try_reset

        display_error_feedback _exc
      end

      def execute_live(_class)
        try_reset

        begin
          build_runner_for(_class).execute
        rescue Exception => exc
          display_error_feedback exc
        end
      end

    private

      def try_reset
        begin
          @manager.reset
        rescue Exception => exc
          # restart manager if reset failed
          @manager.stop rescue nil
          @manager.start

          Utils::Console.error "Something went wrong, restarting live mode:"
          Utils::Console.exception exc
        end
      end

      def build_runner_for(_class)
        raise ArgumentError.new "'#{_class.to_s} is not Interactable" unless _class < Interactable

        Utils::Console.operation "Launching #{_class.to_s}"

        runner = if _class.live_delegate
          build_runner_for _class.live_delegate
        else
          if _class < BaseNavigator
            NavigatorRunner
          elsif _class < BaseReducer
            ReducerRunner
          else
            raise ConfigurationError.new "Don't know how to run #{_class.to_s}, you should provide a navigator or reducer as delegate."
          end.new @manager, _class
        end

        runner.dsl.instance_eval(&_class.live_setup) if _class.live_setup
        runner
      end

      def display_error_feedback(_exc)
        @manager.show_message(
          :error,
          'Crawler error!',
          "#{_exc.class.to_s}: #{_exc.to_s}",
          _exc.backtrace.join("\n")
        )

        Utils::Console.exception _exc
      end

    end
  end
end