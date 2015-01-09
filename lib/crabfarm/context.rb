require 'active_support'

module Crabfarm
  class Context
    extend Forwardable

    def_delegators :@pool, :driver

    def initialize
      @pool = DriverBucketPool.new
      @store = StateStore.new
    end

    def run_state(_name, _params={})
      state = LoaderService.load_state(_name).new @pool, @store, _params
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
