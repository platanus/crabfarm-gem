require 'active_support'

module Crabfarm
  class Context
    extend Forwardable

    def_delegators :@pool, :driver

    def initialize(_module)
      @module = _module
      @pool = DriverBucketPool.new @module
      @store = StateStore.new @module
    end

    def run_state(_name, _params={})
      state = @module.load_state(_name).new @module, @pool, @store, _params
      state.crawl
      state
    end

    def reset
      @store.reset
      @pool.reset
    end

    def release
      @pool.release
    end

  end

end
