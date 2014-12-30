module Crabfarm
  class DriverBucket

    attr_reader :session_id

    def initialize(_module, _session_id, _factory)
      @module = _module
      @session_id = _session_id
      @factory = _factory
      @driver = nil
    end

    def setup(_factory)
      reset
      @factory = _factory
    end

    def parse(_parser_class, _options={})
      _parser_class = @module.load_parser(_parser_class) if _parser_class.is_a? String or _parser_class.is_a? Symbol
      parser = _parser_class.new @module, self, _options
      parser.parse
      return parser
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
