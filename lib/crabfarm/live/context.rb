require 'crabfarm/utils/webdriver'

module Crabfarm
  module Live
    class Context < Crabfarm::Context

      def initialize(_manager)
        @manager = _manager
      end

      def proxy
        "127.0.0.1:#{@manager.proxy_port}"
      end

      def viewer
        @manager
      end

    end
  end
end
