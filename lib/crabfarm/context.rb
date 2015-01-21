require 'active_support'

module Crabfarm
  class Context
    extend Forwardable

    def_delegators :@pool, :driver

    def initialize
      @store = StateStore.new
      @loaded = false
    end

    def load
      unless @loaded
        init_phantom_if_required
        @pool = DriverBucketPool.new build_driver_factory
        @loaded = true
      end
    end

    def run_state(_name, _params={})
      load
      state = LoaderService.load_state(_name).new @pool, @store, _params
      state.crawl
      state
    end

    def reset
      load
      @store.reset
      @pool.reset
    end

    def release
      if @loaded
        @pool.release
        @phantom.stop unless @phantom.nil?
        @loaded = false
      end
    end

  private

    def init_phantom_if_required
      if config.phantom_mode_enabled?
        @phantom = PhantomRunner.new phantom_config
        @phantom.start
      end
    end

    def build_driver_factory
      if @phantom
        PhantomDriverFactory.new @phantom, driver_config
      else
        return config.driver_factory if config.driver_factory
        DefaultDriverFactory.new driver_config
      end
    end

    def config
      Crabfarm.config
    end

    def driver_config
      config.driver_config
    end

    def phantom_config
      config.phantom_config
    end

  end

end
