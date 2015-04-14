module Crabfarm
  module Adapters
    module Browser
      class Noop

        def initialize(_proxy=nil)
        end

        def prepare_driver_services
        end

        def cleanup_driver_services
        end

        def build_driver(_session_id)
          _session_id || :noop
        end

        def release_driver(_driver)
        end

      end
    end
  end
end