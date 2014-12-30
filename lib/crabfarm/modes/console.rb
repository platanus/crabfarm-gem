require 'readline'
require 'rainbow'
require 'rainbow/ext/string'
require 'json'

module Crabfarm
  module Modes
    class Console

      class ConsoleDsl

        attr_reader :context

        def initialize(_loader)
          @loader = _loader
          reload!
        end

        def reload!
          unless @context.nil?
            puts "Reloading crawler source".color(:green)
            @context.release
            @loader.unload
          end

          @context = @loader.load_context
        end

        def transition(_name=nil, _params={})
          if _name.nil?
            puts "Must provide a state name".color(:red)
            return
          end

          begin
            state = @context.run_state _name, _params
            puts JSON.pretty_generate(state.output.attributes!).color(:green)
          rescue EntityNotFoundError => e
            puts "#{e.to_s}".color(:red)
          rescue => e
            puts "#{e.to_s}".color(:red)
            puts e.backtrace
          end
        end

        def help
          puts "Ejem..."
        end

        def reset
          puts "Resetting crawling context".color(:green)
          @context.reset
        end

        alias :t :transition
        alias :r :reset
      end

      def self.console_loop

        if defined? CF_LOADER
          # TODO: generated app should load itself
          dsl = ConsoleDsl.new(CF_LOADER)

          loop do
            begin
              dsl.instance_eval Readline.readline("> ", true)
            rescue SyntaxError => se
              puts "Syntax error: #{se.message}".color(:red)
            rescue SystemExit, Interrupt
              break
            rescue => e
              puts "Unknown command".color(:red)
            end
          end

          puts "Releasing crawling context".color(:green)
          dsl.context.release
        else
          puts "This command can only be run inside a crabfarm application".color(:red)
        end
      end

    end
  end
end
