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
      init_phantom_if_required
      init_driver_pool
      init_http_client
    end

    def reset_services
      @store.reset
      @pool.reset
    end

    def unload_services
      release_driver_pool
      release_http_client
      release_phantom
    end

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
      phantom_port = Utils::PortDiscovery.find_available_port
      new_phantom = PhantomRunner.new phantom_config.merge(port: phantom_port)
      new_phantom.start
      return new_phantom
    end

    def release_phantom
      @phantom.stop unless @phantom.nil?
      @phantom = nil
    end

    def init_http_client
      @http = build_http_client if @http.nil?
    end

    def release_http_client
      @http = nil
    end

    def build_driver_factory
      if @phantom
        PhantomDriverFactory.new @phantom, driver_config
      else
        return config.driver_factory if config.driver_factory
        DefaultDriverFactory.new driver_config
      end
    end

    def build_http_client
      HttpClient.new config.proxy
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
