module Crabfarm
  module Adapters
    module Browser
      class Base

        def headless?
          true
        end

        def build_driver(_session_id)
          ensure_implementation :build_driver
        end

        def reset_driver(_driver)
          nil
        end

        def extract_webdriver(_driver)
          nil
        end

        def release_driver(_driver)
          nil
        end

        def prepare_driver_services
          # Nothing by default
        end

        def cleanup_driver_services
          # Nothing by default
        end

      private

        def ensure_implementation(_name)
          raise NotImplementedError.new "Missing #{_name} implementation on browser adapter"
        end

      end
    end
  end
end