module Crabfarm
  module Strategies

    class Loader
      def initialize(_name, _klass, _pkg, _deps)
        @name = _name
        @klass = _klass
        @pkg = _pkg
        @deps = _deps
      end

      def load
        load_dependencies
        require @pkg if @pkg
        if @klass.is_a? String then Object.const_get @klass else @klass end
      end

    private

      def load_dependencies
        @deps.each do |dep|
          begin
            require dep
            # TODO: check dependency version!
          rescue LoadError
            raise ConfigurationError.new "Missing #{@name} dependency, please add `gem \"#{dep}\"` to the crawler's Gemfile"
          end
        end
      end
    end

    @@register = {}

    def self.register(_cat, _name, _klass, _pkg=nil, _deps=[])
      full_name = _cat.to_s + ':' + _name.to_s
      @@register[full_name] = Loader.new(full_name, _klass, _pkg, _deps)
    end

    def self.load(_cat, _name)
      full_name = _cat.to_s + ':' + _name.to_s
      raise ConfigurationError.new "Invalid #{_cat} name #{_name}" unless @@register.has_key? full_name
      @@register[full_name].load
    end
  end
end
