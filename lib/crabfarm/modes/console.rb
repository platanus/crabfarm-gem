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
            @loader.reload_source
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

      def self.start(_loader)
        dsl = ConsoleDsl.new(_loader)

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
      end

    end
  end
end
