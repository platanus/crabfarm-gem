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

  class StillWorkingError < Error; end

  class TimeoutError < Error; end

  class CrawlerError < Error

    attr_reader :original

    def initialize(_exc)
      super
      @original = _exc
    end

  end

  class LiveInterrupted < StandardError; end

end
