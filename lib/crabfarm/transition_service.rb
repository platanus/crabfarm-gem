module Crabfarm
  class TransitionService

    def self.with_navigator_decorator(_decorator)
      @decorator = DecoratorChain.new @decorator, _decorator
      begin
        yield
      ensure
        @decorator = @decorator.base
      end
    end

    def self.current_decorator
      @decorator
    end

    def self.transition(_context, _name, _params={})
      self.new(_context).transition(_name, _params)
    end

    attr_reader :document, :navigator

    def initialize(_context)
      @context = _context
    end

    def transition(_name, _params={})
      navigator_class = if _name.is_a? String or _name.is_a? Symbol
        load_class_from_uri _name
      else _name end

      @context.prepare
      @navigator = navigator_class.new @context, _params
      @navigator = current_decorator.decorate @navigator unless current_decorator.nil?

      @document = @navigator.run
      @document = @document.as_json if @document.respond_to? :as_json

      self
    end

  private

    def current_decorator
      self.class.current_decorator
    end

    def load_class_from_uri(_uri)
      class_name = Utils::Naming.decode_crabfarm_uri _uri
      class_name.constantize
    end

    class DecoratorChain

      attr_reader :base, :new

      def initialize(_base, _new)
        @base = _base
        @new = _new
      end

      def decorate(_navigator)
        _navigator = @new.decorate _navigator
        return _navigator if @base.nil?
        @base.decorate _navigator
      end

    end

  end
end
