module Crabfarm
  module Strategies

    class Loader
      def initialize(_name, _klass, _options={})
        @name = _name
        @klass = _klass

        @pkg = if _options.key? :require
          _options[:require]
        elsif @klass.is_a? String
          Utils::Naming.route_from_constant(@klass).join('/')
        else nil end

        @requirements = Array(_options[:dependencies]) if _options.key? :dependencies
      end

      def load
        load_requirements unless @requirements.nil?
        require @pkg if @pkg
        if @klass.is_a? String then Object.const_get @klass else @klass end
      end

    private

      def load_requirements
        @requirements.each do |dep|
          begin
            require dep
            # TODO: check dependency version!
          rescue LoadError
            raise ConfigurationError.new "Could not find #{@name} dependency, maybe you forgot to add `gem \"#{dep}\"` to the crawler's Gemfile?"
          end
        end
      end
    end

    @@register = {}

    def self.register(_cat, _name, _klass, _options={})
      full_name = _cat.to_s + ':' + _name.to_s
      @@register[full_name] = Loader.new(full_name, _klass, _options)
    end

    def self.load(_cat, _name)
      full_name = _cat.to_s + ':' + _name.to_s
      raise ConfigurationError.new "Invalid #{_cat} name #{_name}" unless @@register.has_key? full_name
      @@register[full_name].load
    end
  end
end
