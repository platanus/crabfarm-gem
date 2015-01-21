require 'active_support'
require 'crabfarm/crabtrap_runner'

module Crabfarm
  class CrabtrapContext < Context

    def load
      restart_with_options(mode: :pass) if @runner.nil?
      super
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

    def restart_with_options(_options)
      stop_daemon
      @runner = CrabtrapRunner.new Crabfarm.config.crabtrap_config.merge(_options)
      @runner.start
    end

    def stop_daemon
      @runner.stop unless @runner.nil?
    end

    def driver_config
      super.merge(proxy: proxy_address)
    end

    def phantom_config
      super.merge(proxy: proxy_address)
    end

    def proxy_address
      "127.0.0.1:#{@runner.port}"
    end

  end
end
