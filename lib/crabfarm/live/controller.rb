require 'benchmark'
require 'rainbow'
require 'rainbow/ext/string'
require 'crabfarm/modes/console'

require 'crabfarm/support/webdriver_factory'
require 'crabfarm/crabtrap_runner'

require 'crabfarm/live/helpers.rb'
require 'crabfarm/live/navigator_runner.rb'
require 'crabfarm/live/reducer_runner.rb'

module Crabfarm
  module Live
    class Controller

      Colors = Crabfarm::Modes::Console::Colors

      class LiveWarning < StandardError; end

      def initialize(_manager)
        @manager = _manager
      end

      def execute_live(_class)
        begin
          runner = build_runner_for _class
          prepare_session_for runner
          elapsed = Benchmark.measure { runner.execute }
          display_feedback runner, elapsed
        rescue LiveWarning => exc
          display_warning_feedback exc
        rescue Exception => exc
          display_error_feedback exc
        ensure
          clean_up_session
        end
      end

    private

      def build_runner_for(_class)
        raise LiveWarning.new "'#{_class.to_s} is not Interactable" unless _class < Interactable

        puts "Launching #{_class.to_s}".color Colors::NOTICE

        runner = if _class.live_delegate
          build_runner_for _class.live_delegate
        else
          if _class < BaseNavigator
            NavigatorRunner
          elsif _class < BaseReducer
            ReducerRunner
          else
            raise LiveWarning.new "Don't know how to run #{_class.to_s}, you should provide a navigator or reducer as delegate."
          end.new _class
        end

        runner.dsl.instance_eval(&_class.live_setup) if _class.live_setup
        runner
      end

      def prepare_session_for(_runner)
        @manager.stop_crabtrap
        if _runner.memento
          @manager.start_crabtrap :replay, memento_path(_runner.memento)
        else
          @manager.start_crabtrap :pass
        end
      end

      def clean_up_session
        # leave crabtrap running for debugging purposes.
      end

      def display_feedback(_runner, _elapsed)
        load_web_ui

        @manager.primary_driver.execute_script(
          "window.crabfarm.showResults(arguments[0], arguments[1]);",
          _runner.output,
          _elapsed.real
        );

        puts _runner.output.color Colors::RESULT
        puts "Completed in #{_elapsed.real} s".color Colors::NOTICE
      end

      def display_error_feedback(_exc)
        load_web_ui

        @manager.primary_driver.execute_script(
          "window.crabfarm.showError(arguments[0], arguments[1]);",
          "#{_exc.class.to_s}: #{_exc.to_s}",
          _exc.backtrace.join("\n")
        );

        puts "#{_exc.class.to_s}: #{_exc.to_s}".color Colors::ERROR
        puts _exc.backtrace
      end

      def display_warning_feedback(_exc)
        load_web_ui
        puts "Warning: #{_exc.to_s}".color Colors::WARNING
      end

      def load_web_ui
        Helpers.inject_script @manager.primary_driver, 'https://www.crabtrap.io/selectorgadget_combined.js'
        Helpers.inject_style @manager.primary_driver, 'https://www.crabtrap.io/selectorgadget_combined.css'
        Helpers.inject_script @manager.primary_driver, 'https://www.crabtrap.io/tools.js'
        Helpers.inject_style @manager.primary_driver, 'https://www.crabtrap.io/tools.css'

      end

      def memento_path(_name)
        File.join(GlobalState.mementos_path, _name + '.json.gz')
      end

    end
  end
end