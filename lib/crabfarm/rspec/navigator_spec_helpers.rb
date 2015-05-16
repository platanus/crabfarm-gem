require 'crabfarm/rspec/reducer_spy_manager'

module Crabfarm
  module RSpec
    module NavigatorSpecHelpers

      def navigate(_name=nil, _params={})
        ensure_context_for :navigate

        if _name.is_a? Hash
          _params = _name
          _name = nil
        end

        Factories::Reducer.with_decorator spy_manager do
          if _name.nil?
            return nil unless described_class < BaseNavigator # TODO: maybe raise an error here.
            @navigator_state = @last_state = TransitionService.transition @navigator_context, described_class, _params
          else
            @last_state = TransitionService.transition @navigator_context, _name, (_params || {})
          end
        end
      end

      def state
        @navigator_state || navigate(@navigator_params)
      end

      def last_state
        @last_state
      end

      def spy_reducer(_name_or_class)
        ensure_context_for :spy_reducer
        reducer_class = Utils::Resolve.reducer_class _name_or_class
        spy_manager.new_spy_for reducer_class
      end

      def browser(_session_id=nil)
        ensure_context_for :browser
        @navigator_context.pool.driver _session_id
      end

    private

      def spy_manager
        @navigator_spy_manager ||= ReducerSpyManager.new
      end

      def ensure_context_for(_name)
        raise "'#{_name}' is only available in navigator specs." if @navigator_context.nil?
      end

    end
  end
end