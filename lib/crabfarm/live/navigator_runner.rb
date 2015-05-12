require 'json'

module Crabfarm
  module Live
    class NavigatorRunner

      class Dsl
        extend Forwardable

        def initialize(_runner)
          @runner = _runner
        end

        def_delegators :@runner, :use_memento, :use_params, :clear_params, :navigate_to
      end

      def initialize(_target)
        @target = _target
        @params = {}
      end

      def dsl
        @dsl ||= Dsl.new self
      end

      def memento
        if @memento.nil? then memento_for(@target) else @memento end
      end

      def use_memento(_memento)
        @memento = _memento
      end

      def use_params(_params={})
        @params = @params.merge _params
      end

      def clear_params
        @params = {}
      end

      def navigate_to(_navigator, _params={})
      end

      def execute
        context = Crabfarm::Context.new
        begin
          # TODO: execute prerequisites
          @transition = TransitionService.transition context, @target, @params
        ensure
          context.release
        end
      end

      def output
        JSON.pretty_generate(@transition.document).gsub(/(^|\\n)/, '  ')
      end

    private

      def memento_for(_class)
        Utils::Naming.route_from_constant(_class.to_s).join(File::SEPARATOR)
      end

    end
  end
end