module Crabfarm
  class BaseParser < Delegator

    attr_reader :params, :document

    def self.engine(_engine)
      @engine = _engine
    end

    def initialize(_target, _params)
      engine_class = Strategies.load(:parser_engine, class_engine || Crabfarm.config.parser_engine)
      @document = engine_class.parse _target
      @params = _params

      super @document
    end

    def parse
      raise NotImplementedError.new
    end

    def __getobj__
      @document
    end

    def __setobj__(obj)
      @document = obj
    end

  private

    def class_engine
      self.class.instance_variable_get :@engine
    end
  end
end
