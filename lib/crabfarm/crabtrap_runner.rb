require 'timeout'

module Crabfarm
  class CrabtrapRunner

    CRABTRAP_START_TM = 5 # seconds

    def initialize(_config={})
      @config = _config;
      @pid = nil
    end

    def is_running?
      not @pid.nil?
    end

    def port
      @config[:port]
    end

    def mode
      @config.fetch(:mode, :pass).to_sym
    end

    def start
      logger.info "Starting crabtrap in port #{port}"
      @pid = spawn_crabtrap
      logger.info "Crabtrap started (PID: #{@pid})"
    end

    def stop
      unless @pid.nil?
        logger.info "Stopping crabtrap (PID: #{@pid})"
        Process.kill("INT", @pid)
        Process.wait @pid
        logger.info "Crabtrap stopped"
        @pid = nil
      end
    end

  private

    def spawn_crabtrap
      pid = nil
      begin
        pid = Process.spawn({}, crabtrap_cmd)
        Timeout::timeout(CRABTRAP_START_TM) { wait_for_server }
        return pid
      rescue Errno::ENOENT
        raise BinaryMissingError.new 'crabtrap', @config[:bin_path]
      rescue Timeout::Error
        Process.kill "INT", pid
        Process.wait pid
        raise
      end
      pid
    end

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

    def logger
      Crabfarm.logger
    end

  end
end
