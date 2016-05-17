require 'crabfarm/adapters/browser/base'

module Crabfarm
  module Adapters
    module Browser
      class Chenso < Base
        def initialize(_proxy = nil, _proxy_auth = nil)
          @config = load_chenso_config
          @config[:proxy] = _proxy
          @config[:proxy_auth] = _proxy_auth
        end

        def build_driver(_session_id)
          Pincers.for_chenso @config
        end

        def reset_driver(_pincers)
          _pincers
        end

      private

        def load_chenso_config
          {
            # nothing for now
          }
        end

      end
    end
  end
end
