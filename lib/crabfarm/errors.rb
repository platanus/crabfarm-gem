module Crabfarm

  class Error < StandardError; end

  class ConfigurationError < Error; end

  class BinaryMissingError < ConfigurationError

    attr_accessor :binary
    attr_accessor :path

    def initialize(_binary, _path)
      @binary = _binary
      @path = _path
      super "Could not find a suitable version of #{@binary}"
    end

  end

  class AssertionError < Error; end

  class ArgumentError < Error; end

  class ResourceNotFoundError < Crabfarm::Error; end

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
