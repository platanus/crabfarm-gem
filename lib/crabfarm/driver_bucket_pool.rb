module Crabfarm
  class DriverBucketPool

    def initialize
      @buckets = Hash.new
      @phantom = nil

      init_phantom_if_required
    end

    def driver(_session_id=nil)
      _session_id ||= :default_driver
      bucket = @buckets[_session_id.to_sym]
      bucket = @buckets[_session_id.to_sym] = DriverBucket.new(_session_id, build_driver_factory) if bucket.nil?
      bucket
    end

    def reset
      @buckets.values.each(&:reset)
      @buckets = Hash.new
    end

    def release
      reset
      @phantom.stop unless @phantom.nil?
    end

  private

    def init_phantom_if_required
      if config.phantom_mode_enabled?
        @phantom = PhantomRunner.new config.phantom_config
        @phantom.start
      end
    end

    def build_driver_factory
      if config.phantom_mode_enabled?
        PhantomDriverFactory.new @phantom, config.driver_config
      else
        return config.driver_factory if config.driver_factory
        DefaultDriverFactory.new config.driver_config
      end
    end

    def config
      Crabfarm.config
    end

  end
end
