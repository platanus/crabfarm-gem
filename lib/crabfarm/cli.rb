require 'gli'
require 'crabfarm/support/gli'

module Crabfarm
  class CLI
    extend GLI::App

    program_desc 'Crabfarm toolbelt'

    desc "Starts the crawler in console mode"
    command [:console, :c] do |c|

      c.desc "Capture to crabtrap file"
      c.flag [:c, :capture]

      c.desc "Replay from crabtrap file"
      c.flag [:r, :replay]

      Support::GLI.generate_options c

      c.action do |global_options,options,args|
        next puts "This command can only be run inside a crabfarm application" unless defined? CF_PATH

        require "crabfarm/modes/console"
        cb_options = Support::GLI.parse_options options
        cb_options[:crabtrap_bucket] = options[:capture] if options[:capture]
        cb_options[:crabtrap_bucket] = options[:replay] if options[:replay]
        cb_options[:crabtrap_mode] = 'replay' if options[:replay]

        Crabfarm.config.set cb_options # overrides should be set in the executed context (in server mode too)
        Crabfarm::Modes::Console.start
      end
    end

    desc "Starts the crawler in server mode"
    command [:server, :s] do |c|
      c.desc "Set the server host, defaults to 0.0.0.0"
      c.flag [:h,:host]

      c.desc "Set the server port, defaults to 3100"
      c.flag [:p,:port]

      c.desc "Set the server min and max threads, defaults to 0:16"
      c.flag [:t,:threads]

      c.desc "Start the server in verbose mode"
      c.switch :verbose, :default_value => false

      c.desc "Activate code reload before every request"
      c.switch :reload, :default_value => true

      Support::GLI.generate_options c

      c.action do |global_options,options,args|
        next puts "This command can only be run inside a crabfarm application" unless defined? CF_PATH

        require "crabfarm/modes/server"
        server_options = {}
        server_options[:Host] = options[:host] unless options[:host].nil?
        server_options[:Port] = options[:port] || 3100
        server_options[:Threads] = options[:threads] unless options[:threads].nil?
        server_options[:Verbose] = options[:verbose]

        ActiveSupport::Dependencies.mechanism = :require unless options[:reload]
        Crabfarm.config.set Support::GLI.parse_options options
        Crabfarm::Modes::Server.start server_options
      end
    end

    desc "Generates crabfarm scaffolding"
    command [:generate, :g] do |c|

      c.desc "Generates a new crabfarm application"
      c.command :app do |app|
        app.action do |global_options,options,args|
          require "crabfarm/modes/generator"
          Crabfarm::Modes::Generator.new.generate_app(args[0], Dir.pwd)
        end
      end

      c.desc "Generates a new crabfarm parser and parser spec"
      c.command :parser do |parser|
        parser.action do |global_options,options,args|
          require "crabfarm/modes/generator"
          Crabfarm::Modes::Generator.new.generate_parser(args[0])
        end
      end

      c.desc "Generates a new crabfarm state and parser spec"
      c.command :state do |parser|
        parser.action do |global_options,options,args|
          require "crabfarm/modes/generator"
          Crabfarm::Modes::Generator.new.generate_state(args[0])
        end
      end
    end

    desc "Perform an HTTP recording for use in tests"
    command [:record, :r] do |c|
      c.action do |global_options, options, args|
        next puts "This command can only be run inside a crabfarm application" unless defined? CF_PATH

        require "crabfarm/modes/recorder"
        Crabfarm::Modes::Recorder.start args[0]
      end
    end

    command :publish do |c|
      c.action do |global_options,options,args|

      end
    end

    exit run(ARGV)
  end
end
