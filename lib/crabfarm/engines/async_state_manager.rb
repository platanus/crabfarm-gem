require 'benchmark'
require 'ostruct'

module Crabfarm
  module Engines
    class AsyncStateManager

      class LoopAbortedException < StandardError; end

      def initialize(_context)
        @context = _context
        @working = false
        @fatal = nil
        @lock = Mutex.new
      end

      def start
        @lock.synchronize {
          if @thread.nil?
            @fatal = nil
            @thread = Thread.new { crawl_loop }
          end
        }
      end

      def stop
        @lock.synchronize {
          unless @thread.nil?
            @thread.raise LoopAbortedException
            @thread.join
            @thread = nil
          end
        }
      end

      def restart
        stop
        start
      end

      def transition(_name, _params={}, _wait=nil)
        @lock.synchronize {
          if @fatal
            raise CrawlerError.new @fatal
          elsif @working
            raise StillWorkingError.new unless matches_next_state? _name, _params
            wait_and_load_struct _wait
          elsif matches_current_state? _name, _params
            state_as_struct
          else
            @next_state_name = _name
            @next_state_params = _params
            @working = true

            wait_and_load_struct _wait
          end
        }
      end

      def wait_for_state(_wait=nil)
        @lock.synchronize {
          wait_and_load_struct _wait
        }
      end

    private

      def matches_current_state?(_name, _params)
        _name == @state_name and _params == @state_params
      end

      def matches_next_state?(_name, _params)
        _name == @next_state_name and _params == @next_state_params
      end

      def wait_and_load_struct(_wait)
        # need to use this method because mutex are not reentrant and monitors are slow.
        wait_while_working _wait unless _wait.nil?
        raise TimeoutError.new if @working
        state_as_struct
      end

      def wait_while_working(_wait)
        # TODO: use condition variables instead of wait loops
        start = Time.now
        while @working and Time.now - start < _wait.seconds
          @lock.sleep 0.25
        end
      end

      def state_as_struct
        raise CrawlerError.new @fatal if @fatal
        raise CrawlerError.new @error if @error

        OpenStruct.new({
          name: @state_name,
          params: @state_params,
          doc: @doc,
          elapsed: @elapsed
        })
      end

      def crawl_loop
        begin
          loop do
            if @working
              begin
                logger.info "Transitioning state: #{@next_state_name}"
                @elapsed = Benchmark.measure do
                  ActiveSupport::Dependencies.clear
                  @doc = TransitionService.transition(@context, @next_state_name, @next_state_params).output_as_json
                end.real

                logger.info "Transitioned in #{@elapsed.real}"
                @error = nil
              rescue Exception => e
                logger.error "Error during transition:"
                logger.error e
                @doc = nil
                @error = e
              end

              @lock.synchronize {
                @state_name = @next_state_name
                @state_params = @next_state_params
                @working = false
              }
            else sleep 0.2 end
          end
        rescue LoopAbortedException
          logger.info "Manager stopping"

        rescue Exception => e
          logger.fatal "Unhandled exception:"
          logger.fatal e

          @lock.synchronize {
            @fatal = e
          }
        end
      end

      def logger
        Crabfarm.logger
      end
    end
  end
end
