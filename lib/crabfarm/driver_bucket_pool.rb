module Crabfarm
  class DriverBucketPool

    def initialize(_factory=nil)
      @factory = _factory || DefaultDriverFactory.new(Crabfarm.config.driver_config)
      @buckets = Hash.new
    end

    def driver(_session_id=nil)
      _session_id ||= :default_driver
      bucket = @buckets[_session_id.to_sym]
      bucket = @buckets[_session_id.to_sym] = DriverBucket.new(_session_id, @factory) if bucket.nil?
      bucket
    end

    def reset
      @buckets.values.each(&:reset)
      @buckets = Hash.new
    end

    def release
      reset
    end

  end
end
