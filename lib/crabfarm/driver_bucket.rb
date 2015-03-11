module Crabfarm
  class DriverBucket

    attr_reader :session_id

    def initialize(_session_id, _factory)
      @session_id = _session_id
      @factory = _factory
      @driver = nil
    end

    def setup(_factory)
      reset
      @factory = _factory
    end

    def original
      @driver ||= @factory.build_driver(@session_id)
    end

    def reset
      if @driver
        @driver.quit rescue nil
        @driver = nil
      end
      self
    end

    # forward every missing method to actual driver

    def respond_to?(symbol, include_priv=false)
      original.respond_to?(symbol, include_priv)
    end

  private

    def method_missing(method, *args, &block)
      original.__send__(method, *args, &block)
    end

  end
end
