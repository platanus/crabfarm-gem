require 'readline'
require 'rainbow'
require 'rainbow/ext/string'
require 'json'
require 'crabfarm/engines/sync_state_manager'

module Crabfarm
  module Modes
    module Console

      module Colors
        NOTICE = '555555'
        QUESTION = '555555'
        WARNING = :yellow
        ERROR = :red
        RESULT = '00FF00'
      end

      class ConsoleDsl

        def initialize(_manager)
          @manager = _manager
        end

        def reload!
          puts "Reloading crawler source".color Colors::NOTICE
          @manager.reload
          nil
        end

        def reset
          puts "Resetting crawling context".color Colors::NOTICE
          @manager.reset
          nil
        end

        def navigate(_name=nil, _params={})
          if _name.nil?
            puts "Must provide a navigator name".color Colors::ERROR
            return
          end

          begin
            puts "Navigating...".color Colors::NOTICE
            output = @manager.navigate _name, _params
            puts JSON.pretty_generate(output.doc).gsub(/(^|\\n)/, '  ').color Colors::RESULT
            puts "Completed in #{output.elapsed.real} s".color Colors::NOTICE

          rescue Exception => e
            puts "#{e.to_s}".color Colors::ERROR
            puts e.backtrace
          end
        end

        def snap(_name=nil, _params={})
          if _name.nil?
            puts "Must provide a navigator name".color Colors::ERROR
            return
          end

          begin
            puts "Navigating, waiting to hit a reducer...".color Colors::NOTICE
            require 'crabfarm/modes/shared/snapshot_decorator'
            TransitionService.with_navigator_decorator Shared::SnapshotDecorator do
              @manager.navigate _name, _params
            end
            puts "Navigation completed".color Colors::NOTICE

          rescue Exception => e
            puts "#{e.to_s}".color Colors::ERROR
            puts e.backtrace
          end
        end

        def help
          puts "Ejem..."
          nil
        end

        alias :nav :navigate
      end

      def self.process_input(_context)
        dsl = ConsoleDsl.new Engines::SyncStateManager.new _context

        loop do
          begin
            output = dsl.instance_eval Readline.readline("> ", true)
            puts output.inspect unless output.nil?
          rescue SyntaxError => se
            puts "Syntax error: #{se.message}".color(Colors::ERROR)
          rescue SystemExit, Interrupt
            break
          rescue => e
            puts "#{e.to_s}".color(Colors::ERROR)
            puts e.backtrace
          end
        end

        puts "Exiting".color(Colors::NOTICE)
      end

    end
  end
end
