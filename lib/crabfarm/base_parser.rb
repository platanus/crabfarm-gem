module Crabfarm
  class BaseParser

    attr_reader :browser, :params

    def self.browser_dsl(_dsl)
      @browser_dsl = _dsl
    end

    def initialize(_module, _driver, _params)
      dsl_class = Strategies.load(:browser_dsl, class_browser_dsl || _module.settings.browser_dsl)
      @browser = dsl_class.wrap _driver
      @params = _params
    end

    def parse(_params)
      raise NotImplementedError.new
    end

  private

    def class_browser_dsl
      self.class.instance_variable_get :@browser_dsl
    end
  end
end
