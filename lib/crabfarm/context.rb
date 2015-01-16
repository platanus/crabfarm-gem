require 'active_support'

module Crabfarm
  class Context
    extend Forwardable

    attr_accessor :phantom, :crabtrap
    def_delegators :@pool, :driver

    def initialize
      init_crabtrap_if_required
      init_phantom_if_required

      @pool = DriverBucketPool.new build_driver_factory
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

      # unless @crabtrap.nil?
      #   # restart crabtrap
      #   @crabtrap.stop
      #   @crabtrap.start
      # end
    end

    def release
      @pool.release
      @phantom.stop unless @phantom.nil?
      @crabtrap.stop unless @crabtrap.nil?
    end

  private

    def init_crabtrap_if_required
      if config.crabtrap_enabled?
        require "crabfarm/crabtrap_runner"
        @crabtrap = CrabtrapRunner.new config.crabtrap_config
        @crabtrap.start
      end
    end

    def init_phantom_if_required
      if config.phantom_mode_enabled?
        @phantom = PhantomRunner.new override_config(config.phantom_config)
        @phantom.start
      end
    end

    def build_driver_factory
      if config.phantom_mode_enabled?
        PhantomDriverFactory.new @phantom, override_config(config.driver_config)
      else
        return config.driver_factory if override_config(config.driver_factory)
        DefaultDriverFactory.new config.driver_config
      end
    end

    def config
      Crabfarm.config
    end

    def override_config(_config)
      _config[:proxy] = "https://127.0.0.1:#{@crabtrap.port}" unless @crabtrap.nil?
      _config
    end

  end

end
