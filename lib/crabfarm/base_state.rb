require 'thwait'
require 'crabfarm/forked_state'

module Crabfarm
  class BaseState
    extend Forwardable

    attr_reader :params, :output

    def_delegators :@pool, :driver
    def_delegators :@store, :get, :fetch

    def self.browser_dsl(_dsl)
      @class_browser_dsl = _dsl
    end

    def self.output_builder(_builder)
      @class_output_builder = _builder
    end

    def initialize(_module, _pool, _store, _params)
      @module = _module
      @pool = _pool
      @store = _store
      @params = _params

      @dsl = Strategies.load(:browser_dsl, class_browser_dsl || @module.settings.browser_dsl)
      @builder = Strategies.load(:output_builder, class_output_builder || @module.settings.output_builder)
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

  private

    def class_browser_dsl
      self.class.instance_variable_get :@class_browser_dsl
    end

    def class_output_builder
      self.class.instance_variable_get :@class_output_builder
    end
  end
end
