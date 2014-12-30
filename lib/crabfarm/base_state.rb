module Crabfarm
  class BaseState
    extend Forwardable

    attr_reader :params

    def_delegators :@pool, :driver
    def_delegators :@store, :get, :fetch

    def self.browser_dsl(_dsl)
      @class_dsl = _dsl
    end

    def initialize(_module, _pool, _store, _params)
      @module = _module
      @pool = _pool
      @store = _store
      @params = _params
      @output = Jbuilder.new
      @dsl = Adapters.load_from_dsl_name(class_dsl || @module.settings.default_dsl)
    end

    def browser(_name=nil)
      @dsl.wrap driver(_name)
    end

    def output
      @output ||= Jbuilder.new
    end

    def crawl
      raise NotImplementedError.new
    end

  private

    def class_dsl
      self.class.instance_variable_get :@class_dsl
    end
  end
end
