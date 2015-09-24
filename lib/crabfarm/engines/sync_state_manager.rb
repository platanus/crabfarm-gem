require 'ostruct'

module Crabfarm
  module Engines
    class SyncStateManager

      attr_reader :context

      def initialize(_context)
        @context = _context
        @lock = Mutex.new
      end

      def reload
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
          ts = TransitionService.transition(@context, _name, _params)

          OpenStruct.new({
            name: _name,
            params: _params,
            doc: ts.document,
            elapsed: ts.elapsed
          })
        }
      end

    end
  end
end