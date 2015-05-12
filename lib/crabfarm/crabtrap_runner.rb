require 'timeout'
require 'crabfarm/utils/processes'

module Crabfarm
  class CrabtrapRunner

    CRABTRAP_START_TM = 5 # seconds

    def initialize(_config={})
      @config = _config;
      @process = nil
    end

    def is_running?
      not @process.nil?
    end

    def port
      @config[:port]
    end

    def mode
      @config.fetch(:mode, :pass).to_sym
    end

    def start
      logger.info "Starting crabtrap in port #{port}"
      @process = spawn_crabtrap
      logger.info "Crabtrap started (PID: #{@process.pid})"
    end

    def stop
      unless @process.nil?
        logger.info "Stopping crabtrap (PID: #{@process.pid})"
        @process.stop
        @process = nil
        logger.info "Crabtrap stopped"
      end
    end

    def kill
      unless @process.nil?
        logger.info "Killing crabtrap (PID: #{@process.pid})"
        @process.stop 0
        @process = nil
        logger.info "Crabtrap stopped"
      end
    end

  private

    def spawn_crabtrap
      proc = nil
      begin
        proc = Utils::Processes.start_logged_process 'crabtrap', crabtrap_cmd, logger
        Timeout::timeout(CRABTRAP_START_TM) { wait_for_server }
      rescue ChildProcess::LaunchError
        raise BinaryMissingError.new 'crabtrap', @config[:bin_path]
      rescue Timeout::Error
        proc.stop
        raise
      end
      proc
    end

    def crabtrap_cmd
      cmd = [@config[:bin_path]]
      cmd << mode.to_s
      cmd << @config[:bucket_path] if mode != :pass
      cmd << "--port=#{port}"
      cmd
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
