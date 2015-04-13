module Crabfarm
  class Context
    extend Forwardable

    attr_accessor :pool, :store, :http

    def initialize
      @store = StateStore.new
      @loaded = false
    end

    def loaded?
      @loaded
    end

    def prepare
      unless @loaded
        load_services
        @loaded = true
      end
    end

    def reset
      reset_services if @loaded
    end

    def release
      unload_services
      @loaded = false
    end

  private

    def load_services
      init_driver_factory
      init_driver_pool
      init_http_client
    end

    def reset_services
      @store.reset
      @pool.reset
    end

    def unload_services
      release_http_client
      release_driver_pool
      release_driver_factory
    end

    def init_driver_factory
      if @factory.nil?
        @factory = Strategies.load(:driver, config.driver).new proxy
        @factory.prepare_driver_services
      end
    end

    def release_driver_factory
      @factory.cleanup_driver_services unless @factory.nil?
      @factory.nil?
    end

    def init_driver_pool
      @pool = DriverPool.new @factory if @pool.nil?
    end

    def release_driver_pool
      @pool.release unless @pool.nil?
      @pool = nil
    end

    def init_http_client
      @http = HttpClient.new proxy if @http.nil?
    end

    def release_http_client
      @http = nil
    end

    def proxy
      Crabfarm.config.proxy
    end

    def config
      Crabfarm.config
    end

  end
end
