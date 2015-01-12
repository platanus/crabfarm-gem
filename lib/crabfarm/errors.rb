module Crabfarm

  class Error < StandardError; end

  class ConfigurationError < Error; end

  class EntityNotFoundError < Error
    attr_accessor :role, :name

    def initialize(_role, _name)
      super("The required #{_role} was not found (#{_name})")
      @role = _role
      @name = _name
    end
  end

  class ApiError < Error
    def code; 500 end
    def to_json; {} end
  end

  class StillWorkingError < ApiError
    def code; 409 end
  end

  class TimeoutError < ApiError
    def code; 408 end
  end

  class CrawlerBaseError < ApiError
    def initialize(_msg, _trace)
      @exc = _msg
      @trace = _trace
    end

    def to_json
      {
        exception: @exc,
        backtrace: @trace
      }.to_json
    end
  end

  class CrawlerError < CrawlerBaseError
    def initialize(_exc)
      super _exc.to_s, _exc.backtrace
    end
  end

end
