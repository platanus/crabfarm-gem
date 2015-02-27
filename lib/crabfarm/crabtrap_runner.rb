require 'net/http'

module Crabfarm
  class CrabtrapRunner

    def initialize(_config={})
      @config = _config;
      @pid = nil
    end

    def is_running?
      not @pid.nil?
    end

    def port
      @config[:port] # TODO: maybe select port dynamically...
    end

    def mode
      @config.fetch(:mode, :pass).to_sym
    end

    def start
      begin
        @pid = Process.spawn({}, crabtrap_cmd)
        wait_for_server
      rescue
        puts "Could not find crabtrap at #{@config[:bin_path]}, memento replaying is disabled!"
        @pid = nil
      end
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
          # TODO: improve waiting, making this kind of request could change crabtrap's stack
          Net::HTTP.get_response(URI.parse("http://127.0.0.1:#{port}/status"))
          break
        rescue
        end
      end
    end

  end
end
