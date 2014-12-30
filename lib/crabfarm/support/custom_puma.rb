require 'rack/handler'
require 'puma'

module Crabfarm
  module Support
    module CustomPuma

      DEFAULT_OPTIONS = {
        :Host => '0.0.0.0',
        :Port => 3100,
        :Threads => '0:16',
        :Verbose => false
      }

      def self.run(_app, _options = {})

        _options  = DEFAULT_OPTIONS.merge(_options)

        _app = Rack::CommonLogger.new(_app, STDOUT) if _options[:Verbose]

        ENV['RACK_ENV'] = _options[:environment].to_s if _options[:environment]

        server   = Puma::Server.new(_app)
        min, max = _options[:Threads].split(':', 2)

        puts "Puma #{::Puma::Const::PUMA_VERSION} starting..."
        puts "* Min threads: #{min}, max threads: #{max}"
        puts "* Environment: #{ENV['RACK_ENV']}"

        if _options[:Host].start_with? 'unix://'
          puts "* Listening on #{_options[:Host]}"
          server.add_unix_listener _options[:Host][7..-1]
        else
          puts "* Listening on tcp://#{_options[:Host]}:#{_options[:Port]}"
          server.add_tcp_listener _options[:Host], _options[:Port]
        end

        server.min_threads = min
        server.max_threads = max

        begin
          server.run.join
        rescue Interrupt
          puts "* Gracefully stopping, waiting for requests to finish"
          server.stop(true)
          puts "* Goodbye!"
        end

      end

      def self.valid_options
        {
          "Host=HOST"       => "Hostname to listen on (default: localhost), also supports unix sockets if prefixed with unix://",
          "Port=PORT"       => "Port to listen on (default: 8080)",
          "Threads=MIN:MAX" => "min:max threads to use (default 0:16)",
          "Quiet"           => "Don't report each request"
        }
      end
    end

    Rack::Handler.register :crabfarm_puma, CustomPuma
  end
end

