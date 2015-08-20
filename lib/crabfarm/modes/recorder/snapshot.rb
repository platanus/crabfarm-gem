require 'rainbow'
require 'rainbow/ext/string'
require 'crabfarm/modes/console'
require 'crabfarm/utils/rspec_runner'
require 'crabfarm/modes/shared/snapshot_decorator'

module Crabfarm
  module Modes
    module Recorder
      module Snapshot
        extend self

        def start(_context, _navigator)
          return puts "Must provide a navigator name" unless _navigator.is_a? String

          begin
            puts "Navigating using last #{_navigator} spec, waiting to hit a reducer...".color(Console::Colors::NOTICE)
            Factories::Reducer.with_decorator Shared::SnapshotDecorator do
              @example = Utils::RSpecRunner.run_single_spec_for spec_for(_navigator)
            end
            puts "Navigation completed".color(Console::Colors::NOTICE)
          rescue Exception => e
            puts "#{e.to_s}".color Console::Colors::ERROR
            puts e.backtrace
          end
        end

      private

        def spec_for(_class_name)
          route = Utils::Naming.route_from_constant(_class_name)
          route = route.join(File::SEPARATOR)
          route = route + '_spec.rb'
          File.join('spec','navigators', route)
        end

      end
    end
  end
end