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
        next puts "This command can only be ran inside a crabfarm application" unless Crabfarm.inside_crawler_app?

        Crabfarm.config.set Support::GLI.parse_options options

        Crabfarm.with_context options[:memento] do |context|
          require "crabfarm/modes/console"
          Crabfarm::Modes::Console.process_input context
        end
      end
    end

    desc "Starts the crawler in live mode"
    command [:live, :l] do |c|
      c.action do |global_options,options,args|
        next puts "This command can only be ran inside a crabfarm application" unless Crabfarm.inside_crawler_app?

        require "crabfarm/modes/live"
        Crabfarm::Modes::Live.start_watch
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
        next puts "This command can only be ran inside a crabfarm application" unless Crabfarm.inside_crawler_app?

        Crabfarm.config.set Support::GLI.parse_options options

        ActiveSupport::Dependencies.mechanism = :require unless options[:reload]

        server_options = {}
        server_options[:Host] = options[:host] unless options[:host].nil?
        server_options[:Port] = options[:port] || 3100
        server_options[:Threads] = options[:threads] unless options[:threads].nil?
        server_options[:Verbose] = options[:verbose]

        Crabfarm.with_context options[:memento] do |context|
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
          next puts "This command cannot be ran inside a crabfarm application" if Crabfarm.inside_crawler_app?

          require "crabfarm/modes/generator"
          Crabfarm::Modes::Generator.generate_app(Dir.pwd, args[0], options[:remote])
        end
      end

      c.desc "Generates a new crabfarm navigator and navigator spec"
      c.command :navigator do |sub|

        sub.desc "Specifies the navigator target url"
        sub.flag [:u, :url]

        sub.desc "Whether to generate the homonymous reducer or not"
        sub.switch :reducer, :default_value => true

        sub.action do |global_options,options,args|
          next puts "This command can only be ran inside a crabfarm application" unless Crabfarm.inside_crawler_app?

          require "crabfarm/modes/generator"
          Crabfarm::Modes::Generator.generate_navigator(GlobalState.app_path, args[0], options)
          Crabfarm::Modes::Generator.generate_reducer(GlobalState.app_path, args[0]) if options[:reducer]
        end
      end

      c.desc "Generates a new crabfarm reducer and reducer spec"
      c.command :reducer do |sub|
        sub.action do |global_options,options,args|
          next puts "This command can only be ran inside a crabfarm application" unless Crabfarm.inside_crawler_app?

          require "crabfarm/modes/generator"
          Crabfarm::Modes::Generator.generate_reducer(GlobalState.app_path, args[0])
        end
      end

      c.desc "Generates a new crabfarm struct"
      c.command :struct do |sub|
        sub.action do |global_options,options,args|
          next puts "This command can only be ran inside a crabfarm application" unless Crabfarm.inside_crawler_app?

          require "crabfarm/modes/generator"
          Crabfarm::Modes::Generator.generate_struct(GlobalState.app_path, args[0])
        end
      end
    end

    desc "Crawler fixture recorders"
    command [:record, :r] do |c|

      c.desc "Perform a memento recording for use in tests"
      c.command :memento do |memento|

        memento.desc "Run recorder in playback mode"
        memento.switch [:p, :playback], :default_value => false

        memento.action do |global_options, options, args|
          next puts "This command can only be ran inside a crabfarm application" unless Crabfarm.inside_crawler_app?

          require "crabfarm/modes/recorder/memento"
          Crabfarm::Modes::Recorder::Memento.start args[0], options[:playback]
        end

      end

      c.desc "Take snapshots from a navigator run"
      c.command [:snapshot, :snap] do |snap|

        snap.desc "Navigate on a memento"
        snap.flag [:m, :memento]

        snap.desc "Navigation query string, if not given navigator is run in interactive mode"
        snap.flag [:q, :query]

        snap.action do |global_options, options, args|
          next puts "This command can only be ran inside a crabfarm application" unless Crabfarm.inside_crawler_app?

          Crabfarm.with_context options[:memento] do |context|
            require "crabfarm/modes/recorder/snapshot"
            Crabfarm::Modes::Recorder::Snapshot.start context, args[0], options[:query]
          end
        end

      end
    end

    desc "Publish the crawler to the crabfarm.io cloud"
    command :publish do |c|
      c.desc "Just list the files that are beign packaged"
      c.switch :dry, :default_value => false

      c.desc "Don't check for pending changes"
      c.switch :unsafe, :default_value => false

      c.action do |global_options,options,args|
        next puts "This command can only be ran inside a crabfarm application" unless Crabfarm.inside_crawler_app?

        options[:remote] = args[0]

        require "crabfarm/modes/publisher"
        Crabfarm::Modes::Publisher.publish GlobalState.app_path, options
      end
    end

    on_error do |exc|
      case exc
      when BinaryMissingError
        if exc.binary == 'phantomjs'
          puts "Could not find the phantomjs binary at '#{exc.path}', try installing it using 'npm install phantomjs -g' or set the propper path in your project's Crabfile"
          false
        elsif exc.binary == 'crabtrap'
          puts "Could not find the crabtrap binary at '#{exc.path}', try installing it using 'npm install crabtrap -g' or set the propper path in your project's Crabfile"
          false
        else true end
      else
        true
      end
    end

    exit run(ARGV)
  end
end
