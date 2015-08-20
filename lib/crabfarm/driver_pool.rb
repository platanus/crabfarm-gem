module Crabfarm
  class DriverPool

    def initialize(_factory)
      @factory = _factory
      @drivers = Hash.new
    end

    def driver(_session_id=nil)
      _session_id ||= :default_driver
      driver = @drivers[_session_id.to_sym]
      driver = @drivers[_session_id.to_sym] = @factory.build_driver(_session_id) if driver.nil?
      driver
    end

    def reset(_session_id=nil)
      if _session_id.nil?
        @drivers.values.each { |d| @factory.release_driver d }
        @drivers = Hash.new
      else
        _session_id = _session_id.to_sym
        driver = @drivers.delete _session_id
        @factory.release_driver(driver) unless driver.nil?
      end
      nil
    end

    def release
      reset
    end

  end
end
