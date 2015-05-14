require 'timeout'
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

      INJECTION_TM = 5 # seconds

      Colors = Crabfarm::Modes::Console::Colors

      def initialize(_manager)
        @manager = _manager
      end

      def execute_live(_class)
        begin
          runner = build_runner_for _class
          prepare_session_for runner
          elapsed = Benchmark.measure { runner.execute }
          display_feedback runner, elapsed
        rescue Exception => exc
          display_error_feedback exc
        ensure
          clean_up_session
        end
      end

    private

      def build_runner_for(_class)
        raise ArgumentError.new "'#{_class.to_s} is not Interactable" unless _class < Interactable

        puts "Launching #{_class.to_s}".color Colors::NOTICE

        runner = if _class.live_delegate
          build_runner_for _class.live_delegate
        else
          if _class < BaseNavigator
            NavigatorRunner
          elsif _class < BaseReducer
            ReducerRunner
          else
            raise ConfigurationError.new "Don't know how to run #{_class.to_s}, you should provide a navigator or reducer as delegate."
          end.new _class
        end

        runner.dsl.instance_eval(&_class.live_setup) if _class.live_setup
        runner
      end

      def prepare_session_for(_runner)
        @manager.reset _runner.memento
      end

      def clean_up_session
        # leave crabtrap running for debugging purposes.
      end

      def display_feedback(_runner, _elapsed)
        safe_inject do
          load_web_ui
          @manager.primary_driver.execute_script(
            "window.crabfarm.showResults(arguments[0], arguments[1]);",
            _runner.output,
            _elapsed.real
          );
        end

        puts _runner.output.to_s.color Colors::RESULT
        puts "Completed in #{_elapsed.real} s".color Colors::NOTICE
      end

      def display_error_feedback(_exc)
        safe_inject do
          load_web_ui
          @manager.primary_driver.execute_script(
            "window.crabfarm.showError(arguments[0], arguments[1]);",
            "#{_exc.class.to_s}: #{_exc.to_s}",
            _exc.backtrace.join("\n")
          );
        end

        puts "#{_exc.class.to_s}: #{_exc.to_s}".color Colors::ERROR
        puts _exc.backtrace
      end

      def load_web_ui
        Helpers.inject_style @manager.primary_driver, 'https://www.crabtrap.io/selectorgadget_combined.css'
        Helpers.inject_style @manager.primary_driver, 'https://www.crabtrap.io/tools.css'
        Helpers.inject_script @manager.primary_driver, 'https://www.crabtrap.io/selectorgadget_combined.js'
        Helpers.inject_script @manager.primary_driver, 'https://www.crabtrap.io/tools.js'
        Timeout::timeout(INJECTION_TM) { wait_for_injection }
      end

      def wait_for_injection
        while @manager.primary_driver.execute_script "return (typeof window.crabfarm === 'undefined');"
          sleep 1.0
        end
      end

      def safe_inject
        begin
          yield
        rescue SystemExit, Interrupt
          raise
        rescue Exception => e
          Crabfarm.logger.error 'Error injecting web interface'
          Crabfarm.logger.error e
        end
      end

    end
  end
end