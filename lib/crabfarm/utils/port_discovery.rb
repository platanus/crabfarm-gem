module Crabfarm
  module Utils
    module PortDiscovery

      def self.find_available_port
        begin
          socket = Socket.new(:INET, :STREAM, 0)
          socket.bind(Addrinfo.tcp("127.0.0.1", 0))
          return socket.local_address.ip_port
        ensure
          socket.close rescue nil
        end
      end

    end
  end
end