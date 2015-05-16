module Crabfarm
  module Factories
    module Decorable

      class DecoratorChain

        attr_reader :base, :decorator

        def initialize(_base, _decorator)
          @base = _base # al
          @decorator = _decorator
        end

        def prepare(_args)
          obj = if @decorator.respond_to? :prepare
            @decorator.prepare(*_args)
          else nil end

          return obj if @base.nil?
          base_obj = @base.prepare _args
          raise ConfigurationError.new 'Decorator race condition' if obj and base_obj
          obj || base_obj
        end

        def decorate(_obj)
          if @decorator.respond_to? :decorate
            new_obj = @decorator.decorate _obj
            _obj = new_obj if new_obj
          end

          return _obj if @base.nil?
          @base.decorate _obj
        end

      end

      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods

        def with_decorator(_decorator)
          @decorator = DecoratorChain.new @decorator, _decorator
          begin
            return yield
          ensure
            @decorator = @decorator.base
          end
        end

        def build(*_args)
          obj = if @decorator
            @decorator.prepare _args
          else nil end

          if obj.nil?
            obj = default_build(*_args)
          end

          if @decorator
            @decorator.decorate obj
          else obj end
        end

      end

    end

  end
end