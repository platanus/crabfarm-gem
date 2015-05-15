require 'crabfarm/utils/console'
require 'crabfarm/utils/rspec_runner'

module Crabfarm
  module Live
    class NavigatorRspecRunner

      def initialize(_manager, _target)
        @manager = _manager
        @target = _target
      end

      def dsl
        nil
      end

      def execute
        examples = Utils::RSpecRunner.run_spec_for spec_for(@target), live: true

        @manager.inject_web_tools
        if examples.count == 0
          show_empty_warning
        elsif examples.count == 1
          show_example_output examples.first
        else
          show_example_summary examples
        end
      end

    private

      def spec_for(_class)
        route = Utils::Naming.route_from_constant(_class.to_s)
        route = route.join(File::SEPARATOR)
        route = route + '_spec.rb'
        File.join('spec','navigators', route)
      end

      def show_empty_warning
        @manager.show_dialog(
          :warning,
          'No examples were found!',
          'Make sure you have tagged some specs with live: true'
        )

        Utils::Console.warning 'No examples were found!'
      end

      def show_example_summary(_examples)
        total = _examples.count
        error = _examples.select { |e| !e.exception.nil? }.count
        errored = (error > 0)

        if error > 0
          @manager.show_dialog(
            :error,
            'FAILED',
            "#{error} of #{total} tests failed"
          )

          Utils::Console.error "#{total} examples, #{error} failures"
        else
          @manager.show_dialog(
            :success,
            'SUCCESS',
            "All #{total} tests passed!"
          )

          Utils::Console.result "#{total} examples, 0 failures"
        end
      end

      def show_example_output(_example)

        handle_standard_errors _example

        if _example.exception
          @manager.show_dialog(
            :error,
            'FAILED',
            _example.exception.to_s,
            _example.metadata[:result].to_json,
            :json
          )

          Utils::Console.error "1 example, 1 failure"
          Utils::Console.error _example.exception.to_s
          Utils::Console.json_result _example.metadata[:result]
        else
          @manager.show_dialog(
            :success,
            'SUCCESS',
            "\"#{_example.full_description}\"",
            _example.metadata[:result].to_json,
            :json
          )

          Utils::Console.result "1 example, 0 failures"
          Utils::Console.json_result _example.metadata[:result]
        end
      end

      def handle_standard_errors(_example)
        if _example.exception and not _example.exception.is_a? ::RSpec::Expectations::ExpectationNotMetError
          raise _example.exception
        end
      end

    end
  end
end