require 'net/http'

module Crabfarm
  class PhantomRunner

    attr_reader :port

    def initialize(_config={})
      @config = _config;
      @pid = nil
    end

    def start
      find_available_port
      @pid = Process.spawn({}, phantomjs_cmd)
      wait_for_server
    end

    def stop
      unless @pid.nil?
        Process.kill("TERM", @pid)
        Process.wait @pid
        @pid = nil
      end
    end

  private

    def phantomjs_cmd
      cmd = [@config[:bin_path]]
      cmd << '--load-images=false' unless @config[:load_images]
      cmd << "--proxy=#{@config[:proxy]}" unless @config[:proxy].nil?
      cmd << "--webdriver=#{@port}"
      cmd << "--ssl-protocol=#{@config[:ssl]}" unless @config[:ssl].nil?
      cmd << "--ignore-ssl-errors=true"
      cmd << "--webdriver-loglevel=NONE" # TODO: remove when log path is choosen
      # cmd << "--webdriver-logfile=/path/to/log/phantom.log"
      cmd.join(' ')
    end

    def find_available_port
      with_lock do
        server = TCPServer.new('127.0.0.1', 0)
        @port = server.addr[1]
        server.close
      end
    end

    def wait_for_server
      loop do
        begin
          # TODO: generate a valid request to prevent warnings
          Net::HTTP.get_response(URI.parse("http://127.0.0.1:#{@port}"))
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
