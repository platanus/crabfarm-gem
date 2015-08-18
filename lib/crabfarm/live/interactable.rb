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

    end
  end
end
