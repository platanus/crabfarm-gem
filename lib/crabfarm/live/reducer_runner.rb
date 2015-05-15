module Crabfarm
  module Live
    class ReducerRunner < NavigatorRunner

      def initialize(_manager, _target)
        # use navigator runner for now.
        super _manager, navigator_from_reducer(_target)
      end

      def navigator_from_reducer _reducer
        m = _reducer.to_s.match(/^(.*?)Reducer$/)
        if m
          navigator = m[1].constantize rescue nil
          return navigator if navigator and navigator < BaseNavigator
        end

        raise ConfigurationError.new "Could not find a matching navigator for reducer #{_reducer.to_s}"
      end

    end
  end
end