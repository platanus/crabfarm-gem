require 'active_support'
require 'crabfarm/crabtrap_runner'

module Crabfarm
  class CrabtrapContext < Context

    attr_accessor :mode

    def initialize(_mode=:pass, _path=nil)
      @mode = _mode
      @path = _path
    end

    def pass_through
      if not loaded? or @mode != :pass
        @mode = :pass
        @path = nil
        restart
      end
    end

    def capture(_path)
      @mode = :capture
      @path = _path
      restart
    end

    def replay(_path)
      @mode = :replay
      @path = _path
      restart
    end

    def restart
      if not loaded?
        prepare
      else
        stop_daemon
        start_daemon
      end
    end

  private

    def load_services
      @port = Utils::PortDiscovery.find_available_port
      start_daemon
      super
    end

    def reset_services
      restart
    end

    def unload_services
      super
      stop_daemon
      @port = nil
    end

    def build_http_client
      HttpClient.new proxy_address
    end

    def start_daemon
      if @runner.nil?
        options = {
          mode: @mode,
          bucket_path: @path,
          port: @port
        }

        @runner = CrabtrapRunner.new Crabfarm.config.crabtrap_config.merge(options)
        @runner.start
      end
    end

    def stop_daemon
      unless @runner.nil?
        @runner.stop
        @runner = nil
      else nil end
    end

    def driver_config
      super.merge(proxy: proxy_address)
    end

    def phantom_config
      super.merge(proxy: proxy_address)
    end

    def proxy_address
      "127.0.0.1:#{@port}"
    end

  end
end
