module Crabfarm
  class BaseParser < Delegator

    attr_reader :params, :root

    def self.parser_dsl(_dsl)
      @parser_dsl = _dsl
    end

    def initialize(_html, _params)
      dsl_class = Strategies.load(:parser_dsl, class_parser_dsl || Crabfarm.config.parser_dsl)
      @root = dsl_class.parse _html
      @params = _params

      super @root
    end

    def parse
      raise NotImplementedError.new
    end

    def __getobj__
      @root
    end

    def __setobj__(obj)
      @root = obj
    end

  private

    def class_parser_dsl
      self.class.instance_variable_get :@parser_dsl
    end
  end
end
