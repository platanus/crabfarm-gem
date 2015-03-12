module Crabfarm
  class BaseParser < Delegator

    attr_reader :params, :document

    def self.parser_dsl(_dsl)
      @parser_dsl = _dsl
    end

    def initialize(_target, _params)
      dsl_class = Strategies.load(:parser_dsl, class_parser_dsl || Crabfarm.config.parser_dsl)
      @document = dsl_class.parse _target
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

    def class_parser_dsl
      self.class.instance_variable_get :@parser_dsl
    end
  end
end
