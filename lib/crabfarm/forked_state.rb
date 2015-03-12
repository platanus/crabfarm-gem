module Crabfarm
  class ForkedState
    extend Forwardable

    def_delegators :@state, :params, :get, :fetch, :event, :alert, :info, :parse, :method_missing, :respond_to?

    def initialize(_state, _name, _mutex)
      @state = _state
      @name = _name
      @mutex = _mutex
    end

    def driver
      @driver ||= @state.driver(@name)
    end

    def browser
      @browser ||= @state.browser(@name)
    end

    def lock_output
      @mutex.synchronize {
        yield @state.output
      }
    end
  end
end