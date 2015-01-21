require 'net/http'

module Crabfarm
  class CrabtrapRunner

    def initialize(_config={})
      @config = _config;
      @pid = nil
    end

    def port
      @config[:port] # TODO: maybe select port dynamically...
    end

    def mode
      @config.fetch(:mode, :pass).to_sym
    end

    def start
      @pid = Process.spawn({}, crabtrap_cmd)
      # wait_for_server
    end

    def stop
      unless @pid.nil?
        Process.kill("INT", @pid)
        Process.wait @pid
        @pid = nil
      end
    end

  private

    def crabtrap_cmd
      cmd = [@config[:bin_path]]
      cmd << mode.to_s
      cmd << @config[:bucket_path] if mode != :pass
      cmd << "--port=#{port}"
      cmd.join(' ')
    end

    def wait_for_server
      loop do
        begin
          Net::HTTP.get_response(URI.parse("http://127.0.0.1:#{port}/status"))
          break
        rescue
        end
      end
    end

  end
end
