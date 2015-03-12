require 'active_support'

module Crabfarm
  class Context
    extend Forwardable

    attr_accessor :pool, :store

    def initialize
      @store = StateStore.new
      @loaded = false
    end

    def load
      init_phantom_if_required
      init_driver_pool
      @loaded = true
    end

    def reset
      @store.reset
      @pool.reset unless @pool.nil?
    end

    def release
      release_driver_pool
      release_phantom
      @loaded = false
    end

  private

    def init_driver_pool
      @pool = DriverBucketPool.new build_driver_factory if @pool.nil?
    end

    def release_driver_pool
      @pool.release unless @pool.nil?
      @pool = nil
    end

    def init_phantom_if_required
      if config.phantom_mode_enabled? and @phantom.nil?
        @phantom = load_and_start_phantom
      end
    end

    def load_and_start_phantom
      new_phantom = PhantomRunner.new phantom_config
      new_phantom.start
      return new_phantom
    end

    def release_phantom
      @phantom.stop unless @phantom.nil?
      @phantom = nil
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
