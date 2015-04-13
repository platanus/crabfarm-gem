module Crabfarm
  class ForkedState < Delegator

    def initialize(_context, _parent, _browser_name, _mutex)
      @context = _context
      @parent = _parent
      @browser_name = _browser_name
      @mutex = _mutex

      super @parent
    end

    def browser
      @browser ||= @context.pool.driver(@browser_name)
    end

    def output
      raise ScriptError.new 'Use lock_output to access output in forked states'
    end

    def lock_output
      @mutex.synchronize {
        yield @parent.output
      }
    end

    def __getobj__
      @parent
    end

    def __setobj__(obj)
      @parent = obj
    end
  end
end