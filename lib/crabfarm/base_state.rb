require 'thwait'
require 'crabfarm/forked_state'

module Crabfarm
  class BaseState
    extend Forwardable

    PARSE_METHOD_RX = /^parse_(.*)$/

    attr_reader :params, :output

    def_delegators :@pool, :driver
    def_delegators :@store, :get, :fetch

    def self.browser_dsl(_dsl)
      @class_browser_dsl = _dsl
    end

    def self.output_builder(_builder)
      @class_output_builder = _builder
    end

    def initialize(_pool, _store, _params)
      @pool = _pool
      @store = _store
      @params = _params

      @dsl = Strategies.load(:browser_dsl, class_browser_dsl || Crabfarm.config.browser_dsl)
      @builder = Strategies.load(:output_builder, class_output_builder || Crabfarm.config.output_builder)
    end

    def browser(_name=nil)
      @dsl.wrap driver(_name)
    end

    def output
      @output ||= @builder.prepare
    end

    def output_as_json
      @builder.serialize @output
    end

    def crawl
      raise NotImplementedError.new
    end

    def parse(_target=nil, _options={})
      parser_class = _options.delete :using

      if parser_class.nil?
        parser_class = (self.class.name + 'Parser').constantize
      end

      parser = parser_class.new _target, @params.merge(_options)
      parser.parse
      return parser
    end

    def fork_each(_enumerator, &_block)
      session_id = 0
      mutex = Mutex.new
      ths = _enumerator.map do |value|
        session_id += 1
        start_forked_state("th_session_#{session_id}", value, _block, mutex)
      end
      ThreadsWait.all_waits(*ths)
    end

    def method_missing(_method, *_args, &_block)
      m = PARSE_METHOD_RX.match(_method)
      if m
        options = _args[1] || {}
        options[:using] = (m[1].camelize + 'Parser').constantize
        parse _args[0], options
      else super end
    end

    def respond_to?(_method, _include_all=false)
      return true if PARSE_METHOD_RX === _method
      super
    end

  private

    def class_browser_dsl
      self.class.instance_variable_get :@class_browser_dsl
    end

    def class_output_builder
      self.class.instance_variable_get :@class_output_builder
    end

    def start_forked_state(_name, _value, _block, _mutex)
      Thread.new {
        sub_state = ForkedState.new self, _name, _mutex
        begin
          sub_state.instance_exec _value, &_block
        ensure
          sub_state.driver.reset
        end
      }
    end
  end
end
