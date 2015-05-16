require 'crabfarm/utils/console'
require 'crabfarm/utils/rspec_runner'

module Crabfarm
  module Live
    class ReducerRspecRunner < NavigatorRspecRunner

      def prepare(_class, _path, _params) # decorator
        @manager.primary_driver.get("file://#{_path}")
        nil
      end

      def execute
        examples = @manager.block_requests do
          Factories::SnapshotReducer.with_decorator self do
            Utils::RSpecRunner.run_spec_for spec_for(@target), live: true
          end
        end

        show_results_for examples
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