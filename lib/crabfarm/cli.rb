require 'gli'

module Crabfarm
  class CLI
    extend GLI::App

    program_desc 'Crabfarm toolbelt'

    pre do |global_options,command,options,args|
      # Things to do before
      true
    end

    desc "Starts the crawler in console mode"
    command [:console, :c] do |c|
      c.action do |global_options,options,args|
        require "crabfarm/modes/console"
        Crabfarm::Modes::Console.console_loop
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

      c.action do |global_options,options,args|
        require "crabfarm/modes/server"
        server_options = {}
        server_options[:Host] = options[:host] unless options[:host].nil?
        server_options[:Port] = options[:port] || 3100
        server_options[:Threads] = options[:threads] unless options[:threads].nil?
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

    command :publish do |c|
      c.action do |global_options,options,args|

      end
    end

    exit run(ARGV)
  end
end
