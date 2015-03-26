require 'readline'
require 'rainbow'
require 'rainbow/ext/string'
require 'json'
require 'crabfarm/engines/sync_state_manager'

module Crabfarm
  module Modes
    class Console

      class ConsoleDsl < Engines::SyncStateManager

        def reload!
          puts "Reloading crawler source".color(:green)
          super
        end

        def reset
          puts "Resetting crawling context".color(:green)
          super
        end

        def transition(_name=nil, _params={})
          if _name.nil?
            puts "Must provide a state name".color(:red)
            return
          end

          begin
            puts "Transitioning to #{_name.to_s.camelize} state"
            output = super

            puts "State changed, generated document:"
            puts JSON.pretty_generate(output.doc).color(:green).gsub(/(^|\\n)/, '  ')
            puts "Completed in #{output.elapsed.real} s"

          rescue Exception => e
            puts "#{e.to_s}".color(:red)
            puts e.backtrace
          end
        end

        def help
          puts "Ejem..."
        end

        alias :t :transition
        alias :r :reset
      end

      def self.process_input(_context)
        dsl = ConsoleDsl.new _context

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

        puts "Exiting".color(:green)
      end

    end
  end
end
