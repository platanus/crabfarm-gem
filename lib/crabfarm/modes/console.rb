require 'readline'
require 'rainbow'
require 'rainbow/ext/string'
require 'json'
require 'crabfarm/utils/console'
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
          console.info "Reloading crawler source"
          @manager.reload
          nil
        end

        def reset
          console.info "Resetting crawling context"
          @manager.reset
          nil
        end

        def navigate(_name=nil, _params={})
          if _name.nil?
            console.warning "Must provide a navigator name"
            return
          end

          begin
            console.info "Navigating..."
            output = @manager.navigate _name, _params
            console.json_result output.doc
            console.info "Completed in #{output.elapsed.real} s"

          rescue Exception => exc
            console.exception exc
          end
        end

        def snap(_name=nil, _params={})
          if _name.nil?
            console.warning "Must provide a navigator name"
            return
          end

          begin
            console.info "Navigating, waiting to hit a reducer..."
            require 'crabfarm/modes/shared/snapshot_decorator'
            Factories::Reducer.with_decorator Shared::SnapshotDecorator do
              @manager.navigate _name, _params
            end
            console.info "Navigation completed"

          rescue Exception => exc
            console.exception exc
          end
        end

        def help
          console.info "Ejem..."
          nil
        end

        def console
          Crabfarm::Utils::Console
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
            Crabfarm::Utils::Console.exception se
          rescue SystemExit, Interrupt
            break
          rescue => exc
            Crabfarm::Utils::Console.exception exc
          end
        end

        Crabfarm::Utils::Console.system "Exiting"
      end

    end
  end
end
