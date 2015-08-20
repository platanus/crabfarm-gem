require 'crabfarm/live/navigator_runner_rspec'

module Crabfarm
  module Live
    class ReducerRunnerRSpec < NavigatorRunnerRSpec

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