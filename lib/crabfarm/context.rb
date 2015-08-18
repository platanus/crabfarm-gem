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
      init_browser_adapter
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
      release_browser_adapter
    end

    def init_browser_adapter
      if @browser_adapter.nil?
        @browser_adapter = build_browser_adapter proxy
        @browser_adapter.prepare_driver_services
      end
    end

    def release_browser_adapter
      @browser_adapter.cleanup_driver_services unless @browser_adapter.nil?
      @browser_adapter.nil?
    end

    def init_driver_pool
      @pool = DriverPool.new @browser_adapter if @pool.nil?
    end

    def release_driver_pool
      @pool.release unless @pool.nil?
      @pool = nil
    end

    def init_http_client
      @http = build_http_client proxy if @http.nil?
    end

    def build_browser_adapter(_proxy)
      Strategies.load(:browser, config.browser).new _proxy
    end

    def build_http_client(_proxy)
      HttpClient.new _proxy
    end

    def release_http_client
      @http = nil
    end

    def proxy
      config.proxy
    end

    def config
      Crabfarm.config
    end

  end
end
