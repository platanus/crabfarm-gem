module Crabfarm
  class ForkedState < Delegator

    def initialize(_state, _name, _mutex)
      @state = _state
      @name = _name
      @mutex = _mutex

      super @state
    end

    def driver
      @driver ||= @state.driver(@name)
    end

    def browser
      @browser ||= @state.browser(@name)
    end

    def output
      raise ScriptError.new 'Use lock_output to access output in forked states'
    end

    def lock_output
      @mutex.synchronize {
        yield @state.output
      }
    end

    def __getobj__
      @state
    end

    def __setobj__(obj)
      @state = obj
    end
  end
end