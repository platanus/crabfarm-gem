module Crabfarm
  class TransitionService

    def self.transition(_context, _name, _params={})
      self.new(_context).transition(_name, _params)
    end

    attr_reader :output, :navigator

    def initialize(_context)
      @context = _context
    end

    def transition(_name, _params={})
      navigator_class = if _name.is_a? String or _name.is_a? Symbol
        load_class_from_uri _name
      else _name end

      @context.prepare
      @navigator = navigator_class.new @context, _params
      @output = @navigator.run

      self
    end

    def output_as_json
      if @output.respond_to? :as_json
        @output.as_json
      else @output end
    end

  private

    def load_class_from_uri(_uri)
      class_name = Utils::Naming.decode_crabfarm_uri _uri
      class_name.constantize
    end

  end
end
