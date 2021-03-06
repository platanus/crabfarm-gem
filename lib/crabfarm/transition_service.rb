require 'benchmark'

module Crabfarm
  class TransitionService

    def self.transition(_context, _name, _params={})
      self.new(_context).transition(_name, _params)
    end

    attr_reader :document, :navigator, :elapsed

    def initialize(_context)
      @context = _context
    end

    def transition(_name_or_class, _params={})
      navigator_class = Utils::Resolve.navigator_class _name_or_class

      @elapsed = Benchmark.measure do
        @context.prepare
        @navigator = Factories::Navigator.build navigator_class, @context, _params
        @document = @navigator.run
      end.real

      self
    end

  end
end
