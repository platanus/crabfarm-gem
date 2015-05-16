require 'crabfarm/rspec/reducer_spy'

module Crabfarm
  module RSpec

    class ReducerSpyManager

      def initialize
        @spies = {}
      end

      def new_spy_for(_reducer_class)
        @spies[_reducer_class.to_s] = ReducerSpy.new(_reducer_class)
      end

      # reducer decorator implementation

      def prepare(_class, _target, _params)
        spy = @spies[_class.to_s]
        unless spy.nil?
          spy.register_call _target, _params
          if spy.mock
            mock = _class.new _target, _params
            mock.mock spy.mock

            def mock.run
              # do nothing
            end

            return mock
          end
        end
        nil
      end

    end
  end
end