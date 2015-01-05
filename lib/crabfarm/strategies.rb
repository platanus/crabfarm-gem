module Crabfarm
  module Strategies

    class Loader
      def initialize(_klass, _pkg=nil)
        @klass = _klass
        @pkg = _pkg
      end

      def load
        require @pkg if @pkg
        if @klass.is_a? String then Object.const_get @klass else @klass end
      end
    end

    @@register = {}

    def self.register(_cat, _name, _klass, _pkg=nil)
      @@register[_cat.to_s + _name.to_s] = Loader.new(_klass, _pkg)
    end

    def self.load(_cat, _name)
      full_name = _cat.to_s + _name.to_s
      raise ConfigurationError.new "Invalid #{_cat} name #{_name}" unless @@register.has_key? full_name
      @@register[full_name].load
    end
  end
end
