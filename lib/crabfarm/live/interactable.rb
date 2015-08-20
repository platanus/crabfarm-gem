module Crabfarm
  module Live
    module Interactable

      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods

        def live(_options={}, &_setup)
          @delegate = _options[:delegate]
          @setup = _setup
        end

        def live_rspec?
          @setup.nil?
        end

        def live_delegate
          @delegate
        end

        def live_setup
          @setup
        end

      end

      def examine(_tools=true)
        if Crabfarm.live?
          Crabfarm.live.show_primary_contents if self.is_a? BaseNavigator
          Crabfarm.live.show_content raw_document if self.is_a? BaseReducer
          Crabfarm.live.show_selector_gadget if _tools
          raise LiveInterrupted.new
        end
      end

    end
  end
end
