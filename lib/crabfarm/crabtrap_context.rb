require 'active_support'
require 'crabfarm/crabtrap_runner'

module Crabfarm
  class CrabtrapContext < Context

    def load
      pass_through if @runner.nil?
      super
    end

    def pass_through
      restart_with_options(mode: :pass) if @runner.nil? or @runner.mode != :pass
    end

    def capture(_path)
      restart_with_options(mode: :capture, bucket_path: _path)
    end

    def replay(_path)
      restart_with_options(mode: :replay, bucket_path: _path)
    end

    def release
      super
      stop_daemon
    end

  private

    def build_http_client
      HttpClient.new proxy_address
    end

    def restart_with_options(_options)
      stop_daemon
      @runner = CrabtrapRunner.new Crabfarm.config.crabtrap_config.merge(_options)
      @runner.start
    end

    def stop_daemon
      @runner.stop unless @runner.nil?
    end

    def driver_config
      if @runner.is_running? then super.merge(proxy: proxy_address) else super end
    end

    def phantom_config
      if @runner.is_running? then super.merge(proxy: proxy_address) else super end
    end

    def proxy_address
      "127.0.0.1:#{@runner.port}"
    end

  end
end
