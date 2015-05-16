require 'thwait'
require 'crabfarm/base'
require 'crabfarm/assertion/context'
require 'crabfarm/live/interactable'
require 'crabfarm/forked_navigator'

module Crabfarm
  class BaseNavigator
    include Base
    include Assertion::Context
    include Live::Interactable
    extend Forwardable

    attr_reader :params

    def_delegators '@context', :http
    def_delegators '@context.store', :get, :fetch

    def initialize(_context,  _params)
      @context = _context
      @params = _params
    end

    def browser(_name=nil)
      @context.pool.driver(_name)
    end

    def download(_url)
      @context.http.get(_url).body
    end

    def run
      raise NotImplementedError.new
    end

    def reduce(_target=nil, _options={})
      if _target.is_a? Hash
        _options = _target
        _target = browser
      elsif _target.nil?
        _target = browser
      end

      reduce_using(_options.delete(:using) || self.class.name, _target, _options)
    end

    alias :reduce_with_defaults :reduce

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

    def reduce_using(_reducer_class, _target, _options={})
      if _reducer_class.is_a? String or _reducer_class.is_a? Symbol
        _reducer_class = (Utils::Naming.decode_crabfarm_uri(_reducer_class.to_s) + 'Reducer').constantize
      end

      reducer = Factories::Reducer.build _reducer_class, _target, @params.merge(_options)
      reducer.run
      reducer
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
