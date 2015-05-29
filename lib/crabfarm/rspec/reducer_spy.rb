module Crabfarm
  module RSpec
    class ReducerSpy

      Call = Struct.new(:target, :params)

      attr_reader :original, :mock, :calls

      def initialize(_original)
        @original = _original
        @calls = []
        @mock = nil
      end

      def register_call(_target, _params)
        @calls << Call.new(_target, _params)
      end

      def target
        raise "'#{@original.to_s}' was not invoked" if calls.size == 0
        calls.first.target
      end

      def params
        raise "'#{@original.to_s}' was not invoked" if calls.size == 0
        calls.first.params
      end

      def mock_with(_attributes)
        @mock = _attributes
        self
      end

    end
  end
end