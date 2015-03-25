require 'gli'
require 'crabfarm/support/gli'

module Crabfarm
  class CLI
    extend GLI::App

    program_desc 'Crabfarm toolbelt'

    desc "Starts the crawler in console mode"
    command [:console, :c] do |c|

      c.desc "Use a recorded memento as data source, requires crabtrap"
      c.flag [:m, :memento]

      Support::GLI.generate_options c

      c.action do |global_options,options,args|
        next puts "This command can only be run inside a crabfarm application" unless GlobalState.inside_crawler_app?

        Crabfarm.config.set Support::GLI.parse_options options

        ContextFactory.with_context options[:memento] do |context|
          require "crabfarm/modes/console"
          Crabfarm::Modes::Console.process_input context
        end
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

      c.desc "Use a recorded memento as data source, requires crabtrap"
      c.flag [:m, :memento]

      c.desc "Start the server in verbose mode"
      c.switch :verbose, :default_value => false

      c.desc "Activate code reload before every request"
      c.switch :reload, :default_value => true

      Support::GLI.generate_options c

      c.action do |global_options,options,args|
        next puts "This command can only be run inside a crabfarm application" unless GlobalState.inside_crawler_app?

        Crabfarm.config.set Support::GLI.parse_options options

        ActiveSupport::Dependencies.mechanism = :require unless options[:reload]

        server_options = {}
        server_options[:Host] = options[:host] unless options[:host].nil?
        server_options[:Port] = options[:port] || 3100
        server_options[:Threads] = options[:threads] unless options[:threads].nil?
        server_options[:Verbose] = options[:verbose]

        ContextFactory.with_context options[:memento] do |context|
          require "crabfarm/modes/server"
          Crabfarm::Modes::Server.serve context, server_options
        end
      end
    end

    desc "Generates crabfarm scaffolding"
    command [:generate, :g] do |c|

      c.desc "Generates a new crabfarm application"
      c.command :app do |app|
        app.desc "Set the remote used by the crawler"
        app.flag [:r, :remote]

        app.action do |global_options,options,args|
          next puts "This command cannot be run inside a crabfarm application" if GlobalState.inside_crawler_app?

          require "crabfarm/modes/generator"
          Crabfarm::Modes::Generator.generate_app(Dir.pwd, args[0], options[:remote])
        end
      end

      c.desc "Generates a new crabfarm parser and parser spec"
      c.command :parser do |parser|
        parser.action do |global_options,options,args|
          next puts "This command can only be run inside a crabfarm application" unless GlobalState.inside_crawler_app?

          require "crabfarm/modes/generator"
          Crabfarm::Modes::Generator.generate_parser(GlobalState.app_path, args[0])
        end
      end

      c.desc "Generates a new crabfarm state and parser spec"
      c.command :state do |parser|
        parser.action do |global_options,options,args|
          next puts "This command can only be run inside a crabfarm application" unless GlobalState.inside_crawler_app?

          require "crabfarm/modes/generator"
          Crabfarm::Modes::Generator.generate_state(GlobalState.app_path, args[0])
        end
      end
    end

    desc "Perform an HTTP recording for use in tests"
    command [:record, :r] do |c|
      c.desc "Run recorder in playback mode"
      c.switch [:p, :playback], :default_value => false

      c.action do |global_options, options, args|
        next puts "This command can only be run inside a crabfarm application" unless GlobalState.inside_crawler_app?

        require "crabfarm/modes/recorder"
        Crabfarm::Modes::Recorder.start GlobalState.memento_path(args[0]), options[:playback]
      end
    end

    desc "Publish the crawler to the crabfarm.io cloud"
    command :publish do |c|
      c.desc "Just list the files that are beign packaged"
      c.switch :dry, :default_value => false

      c.desc "Don't check for pending changes"
      c.switch :unsafe, :default_value => false

      c.action do |global_options,options,args|
        next puts "This command can only be run inside a crabfarm application" unless defined? CF_PATH

        options[:remote] = args[0]

        require "crabfarm/modes/publisher"
        Crabfarm::Modes::Publisher.publish CF_PATH, options
      end
    end

    exit run(ARGV)
  end
end
