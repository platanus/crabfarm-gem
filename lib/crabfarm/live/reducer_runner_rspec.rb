require 'crabfarm/utils/rspec_runner'
require 'crabfarm/live/navigator_runner_rspec'

module Crabfarm
  module Live
    class ReducerRunnerRSpec < NavigatorRunnerRSpec

      def execute
        @examples = Utils::RSpecRunner.run_spec_for spec_for(@target), live: true
      end

    private

      def spec_for(_class)
        route = Utils::Naming.route_from_constant(_class.to_s)
        route = route.join(File::SEPARATOR)
        route = route + '_spec.rb'
        File.join('spec','reducers', route)
      end

    end
  end
end