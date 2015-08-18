require "crabfarm/adapters/browser/base"

module Crabfarm
  module Adapters
    module Browser
      class Noop < Base

        def initialize(_proxy=nil)
        end

        def build_driver(_session_id)
          _session_id || :noop
        end

      end
    end
  end
end