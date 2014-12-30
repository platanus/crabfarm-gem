module Crabfarm
  class DriverBucketPool

    def initialize(_module)
      @module = _module
      @buckets = Hash.new
      @phantom = nil

      init_phantom_if_required
    end

    def driver(_session_id=nil)
      _session_id ||= :default_driver
      bucket = @buckets[_session_id.to_sym]
      bucket = @buckets[_session_id.to_sym] = DriverBucket.new(@module, _session_id, build_driver_factory) if bucket.nil?
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
      if @module.settings.phantom_enabled?
        @phantom = PhantomRunner.new @module.settings.phantom_config
        @phantom.start
      end
    end

    def build_driver_factory
      if @module.settings.phantom_enabled?
        PhantomDriverFactory.new @phantom, @module.settings.driver_config
      else
        return @module.settings.driver_factory if @module.settings.driver_factory
        DefaultDriverFactory.new @module.settings.driver_config
      end
    end

  end
end
