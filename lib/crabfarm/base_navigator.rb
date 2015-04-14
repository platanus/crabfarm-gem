require 'thwait'
require 'crabfarm/forked_navigator'
require "crabfarm/assertion/context"

module Crabfarm
  class BaseNavigator
    include Assertion::Context
    extend Forwardable

    attr_reader :params, :output

    def_delegators '@context', :http
    def_delegators '@context.store', :get, :fetch

    def self.output_builder(_builder)
      @class_output_builder = _builder
    end

    def initialize(_context, _params)
      @context = _context
      @params = _params

      @builder = Strategies.load(:output_builder, class_output_builder || Crabfarm.config.output_builder)
      @output = @builder.prepare
    end

    def browser(_name=nil)
      @context.pool.driver(_name)
    end

    def download(_url)
      @context.http.get(_url).body
    end

    def output
      @output
    end

    def output_as_json
      @builder.serialize @output
    end

    def run
      raise NotImplementedError.new
    end

    def reduce(_target=nil, _options={})
      reducer_class = _options.delete :using

      reducer_class = case reducer_class
      when nil
        (self.class.name + 'Reducer').constantize
      when String, Symbol
        (Utils::Naming.decode_crabfarm_uri(reducer_class.to_s) + 'Reducer').constantize
      else reducer_class end

      reducer = reducer_class.new _target, @params.merge(_options)
      reducer.run
      return reducer
    end

    def fork_each(_enumerator, &_block)
      session_id = 0
      mutex = Mutex.new
      ths = _enumerator.map do |value|
        session_id += 1
        start_forked_navigation("th_session_#{session_id}", value, _block, mutex)
      end
      ThreadsWait.all_waits(*ths)
    end

  private

    def class_output_builder
      self.class.instance_variable_get :@class_output_builder
    end

    def start_forked_navigation(_name, _value, _block, _mutex)
      Thread.new {
        fork = ForkedNavigator.new @context, self, _name, _mutex
        begin
          fork.instance_exec _value, &_block
        ensure
          @context.pool.reset _name
        end
      }
    end
  end
end
