require 'rainbow'
require 'rainbow/ext/string'
require 'crabfarm/modes/console'
require 'crabfarm/modes/shared/snapshot_decorator'
require 'crabfarm/modes/shared/interactive_decorator'

module Crabfarm
  module Modes
    module Recorder
      module Snapshot
        extend self

        def start(_context, _navigator, _query=nil)
          return puts "Must provide a navigator name" unless _navigator.is_a? String

          puts "Navigating, waiting to hit a reducer...".color(Console::Colors::NOTICE)
          service.with_navigator_decorator Shared::SnapshotDecorator do
            if _query.nil?
              service.with_navigator_decorator Shared::InteractiveDecorator do
                service.transition _context, _navigator
              end
            else
              _query = parse_query_string _query
              service.transition _context, _navigator, _query
            end
          end
          puts "Navigation completed".color(Console::Colors::NOTICE)
        end

      private

        def service
          TransitionService
        end

        def parse_query_string(_string)
          result = {}

          parts = _string.split '&'
          parts.each do |part|
            key, val = part.split '='
            result[key.to_sym] = Shared::InteractiveDecorator::InteractiveHash.parse_input val
          end

          result
        end

      end
    end
  end
end