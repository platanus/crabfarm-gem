require 'benchmark'
require 'ostruct'

module Crabfarm
  module Engines
    class SyncStateManager

      def initialize(_context)
        @context = _context
        @lock = Mutex.new
      end

      def reload!
        @lock.synchronize {
          ActiveSupport::Dependencies.clear
          @context.reset
        }
      end

      def reset
        @lock.synchronize {
          @context.reset
        }
      end

      def navigate(_name, _params={})
        @lock.synchronize {
          output = { name: _name, params: _params }

          output[:elapsed] = Benchmark.measure do
            output[:doc] = TransitionService.transition(@context, _name, _params).document
          end

          OpenStruct.new output
        }
      end

    end
  end
end