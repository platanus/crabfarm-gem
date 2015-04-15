module Crabfarm
  class ForkedNavigator < Delegator

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

    def synchronize
      @mutex.synchronize {
        yield
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