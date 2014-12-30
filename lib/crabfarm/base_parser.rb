module Crabfarm
  class BaseParser

    attr_reader :browser, :params

    def self.browser_dsl(_dsl)
      @dsl = _dsl
    end

    def initialize(_module, _driver, _params)
      dsl_class = Adapters.load_from_dsl_name(class_dsl || _module.settings.default_dsl)
      @browser = dsl_class.wrap _driver
      @params = _params
    end

    def parse
      raise NotImplementedError.new
    end

  private

    def class_dsl
      self.class.instance_variable_get :@dsl
    end
  end
end
