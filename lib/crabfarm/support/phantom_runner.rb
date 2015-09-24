require 'timeout'
require 'crabfarm/utils/processes'

module Crabfarm
  module Support
    class PhantomRunner

      PHANTOM_START_TM = 5 # seconds

      def initialize(_config={})
        @config = _config;
        @process = nil
      end

      def port
        @config[:port]
      end

      def start
        logger.info "Starting phantomjs in port #{port}"
        @process = spawn_phantomjs
        logger.info "Phantomjs started (PID: #{@process.pid})"
      end

      def stop
        unless @process.nil?
          logger.info "Stopping phantomjs (PID: #{@process.pid})"
          @process.stop
          @process = nil
          logger.info "Phantomjs stopped"
        end
      end

    private

      def spawn_phantomjs
        proc = nil
        begin
          proc = Utils::Processes.start_logged_process 'phantomjs', phantomjs_cmd, logger
          Timeout::timeout(PHANTOM_START_TM) { wait_for_server }
        rescue ChildProcess::LaunchError
          raise BinaryMissingError.new 'phantomjs', @config[:bin_path]
        rescue Timeout::Error
          proc.stop
          raise
        end
        proc
      end

      def phantomjs_cmd
        cmd = [@config[:bin_path]]
        cmd << '--load-images=false' unless @config[:load_images]
        cmd << "--proxy=#{@config[:proxy]}" unless @config[:proxy].nil?
        cmd << "--webdriver=#{port}"
        cmd << "--ssl-protocol=#{@config[:ssl]}" unless @config[:ssl].nil?
        cmd << "--ignore-ssl-errors=true"
        cmd << "--web-security=false"
        cmd << "--webdriver-loglevel=#{@config[:log_level].to_s.upcase}"
        cmd
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

      def logger
        Crabfarm.logger
      end

    end
  end
end