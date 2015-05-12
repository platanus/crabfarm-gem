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

        def live_delegate
          @delegate
        end

        def live_setup
          @setup
        end

      end

      # TODO: Tooling

      # def debugger
      #   if Crabfarm.live? then else end
      # end

      # def highlight(_element)
      #   if Crabfarm.live? then else end
      # end

      # def console
      #   if Crabfarm.live? then else end
      # end

    end
  end
end
