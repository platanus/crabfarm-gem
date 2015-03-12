require 'timeout'

module Crabfarm
  class PhantomRunner

    PHANTOM_START_TM = 5 # seconds

    attr_reader :port

    def initialize(_config={})
      @config = _config;
      @pid = nil
    end

    def start
      find_available_port
      Crabfarm.logger.info "Starting phantomjs in port #{@port}"
      @pid = spawn_phantomjs
      Crabfarm.logger.info "Phantomjs started (PID: #{@pid})"
    end

    def stop
      unless @pid.nil?
        Crabfarm.logger.info "Stopping phantomjs (PID: #{@pid})"
        Process.kill "INT", @pid
        Process.wait @pid, Process::WNOHANG
        Crabfarm.logger.info "Phantomjs stopped (PID: #{@pid})"
        @pid = nil
      end
    end

  private

    def spawn_phantomjs
      pid = Process.spawn({}, phantomjs_cmd)
      begin
        Timeout::timeout(PHANTOM_START_TM) { wait_for_server }
      rescue Timeout::Error
        Process.kill "INT", pid
        Process.wait pid
        raise
      end
      return pid
    end

    def phantomjs_cmd
      cmd = [@config[:bin_path]]
      cmd << '--load-images=false' unless @config[:load_images]
      cmd << "--proxy=#{@config[:proxy]}" unless @config[:proxy].nil?
      cmd << "--webdriver=#{@port}"
      cmd << "--ssl-protocol=#{@config[:ssl]}" unless @config[:ssl].nil?
      cmd << "--ignore-ssl-errors=true"
      cmd << "--webdriver-loglevel=WARN"
      cmd << "--webdriver-logfile=#{@config[:log_file]}" unless @config[:log_file].nil?
      cmd.join(' ')
    end

    def find_available_port
      with_lock do
        socket = Socket.new(:INET, :STREAM, 0)
        socket.bind(Addrinfo.tcp("127.0.0.1", 0))
        @port = socket.local_address.ip_port
        socket.close
      end
    end

    def wait_for_server
      loop do
        begin
          Net::HTTP.get_response(URI.parse("http://127.0.0.1:#{@port}/status"))
          break
        rescue
        end
      end
    end

    def with_lock
      return yield if @config[:lock_file].nil?

      File.open(@config[:lock_file], 'a+') do |file|
        begin
          file.flock File::LOCK_EX
          return yield
        ensure
          file.flock File::LOCK_UN
        end
      end
    end

  end
end
