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

    def start_daemon
      if @runner.nil?
        options = {
          mode: @mode,
          bucket_path: @path,
          port: @port
        }

        @runner = CrabtrapRunner.new config.crabtrap_config.merge(options)
        @runner.start
      end
    end

    def stop_daemon
      unless @runner.nil?
        @runner.kill
        @runner = nil
      else nil end
    end

    def proxy
      proxy_address
    end

    def proxy_auth
      nil
    end

    def proxy_address
      "127.0.0.1:#{@port}"
    end
  end
end
