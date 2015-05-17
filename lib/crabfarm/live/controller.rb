require 'crabfarm/utils/console'
require 'crabfarm/live/navigator_runner'
require 'crabfarm/live/reducer_runner'

module Crabfarm
  module Live
    class Controller

      def initialize(_manager)
        @manager = _manager
      end

      def execute_live(_class)
        begin
          runner = build_runner_for _class
          prepare_session_for runner
          runner.execute
        rescue Exception => exc
          display_error_feedback exc
        ensure
          clean_up_session
        end
      end

    private

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

      def prepare_session_for(_runner)
        @manager.reset_driver_status
      end

      def clean_up_session
        # leave crabtrap running for debugging purposes.
      end

      def display_error_feedback(_exc)
        @manager.inject_web_tools
        @manager.show_dialog(
          :error,
          'Navigation error!',
          "#{_exc.class.to_s}: #{_exc.to_s}",
          _exc.backtrace.join("\n")
        )

        Utils::Console.exception _exc
      end

    end
  end
end