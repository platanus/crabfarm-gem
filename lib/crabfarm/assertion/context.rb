require "crabfarm/assertion/wrapper"

module Crabfarm
  module Assertion
    module Context

      def assert(_value)
        Wrapper.new _value, self
      end

    end
  end
end