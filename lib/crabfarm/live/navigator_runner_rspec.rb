require 'crabfarm/utils/console'
require 'crabfarm/utils/rspec_runner'

module Crabfarm
  module Live
    class NavigatorRunnerRSpec

      attr_reader :example

      def initialize(_manager, _target)
        @manager = _manager
        @target = _target
      end

      def execute
        @example = Utils::RSpecRunner.run_single_spec_for spec_for(@target), :live
        bubble_standard_errors
      end

      def show_results
        if example.nil?
          show_empty_warning
        else
          show_example_output
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
        @manager.show_message(
          :warning,
          "No examples were found!",
          "You will need to write at least one spec for #{@target.to_s}"
        )

        console.warning 'No examples were found!'
      end

      def show_example_output
        if example.exception
          @manager.show_message(
            :error,
            'FAILED',
            example.exception.to_s,
            example.metadata[:result].to_json,
            :json
          )

          console.error "Example \"#{example.full_description}\" failed (line: #{example.metadata[:line_number]})"
          console.error example.exception.to_s
          console.json_result example.metadata[:result]
        else
          @manager.show_message(
            :success,
            'SUCCESS',
            "\"#{example.full_description}\"",
            example.metadata[:result].to_json,
            :json
          )

          console.result "Example \"#{example.full_description}\" passed (line: #{example.metadata[:line_number]})"
          console.json_result example.metadata[:result]
        end
      end

      def bubble_standard_errors
        if example and example.exception and not example.exception.is_a? expectation_error
          raise example.exception
        end
      end

      def expectation_error
        ::RSpec::Expectations::ExpectationNotMetError
      end

      def console
        Utils::Console
      end

    end
  end
end