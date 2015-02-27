require 'benchmark'
require 'ostruct'

module Crabfarm
  module Engines
    class SafeStateLoop

      def initialize
        @running = true
        @working = false
        @lock = Mutex.new
        @thread = Thread.new { crawl_loop }
      end

      def release
        @running = false
        @thread.join
      end

      def change_state(_name, _params={}, _wait=nil)
        @lock.synchronize {
          if @working
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

      def cancel
        @lock.synchronize {
          if @working
            @thread.terminate
            @thread.join
            @thread = Thread.new { crawl_loop }
            @working = false
          end
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
        raise CrawlerError.new @error if @error

        OpenStruct.new({
          name: @state_name,
          params: @state_params,
          doc: @doc,
          elapsed: @elapsed
        })
      end

      def crawl_loop
        context = Crabfarm::Context.new

        begin
          while @running
            if @working
              @elapsed = Benchmark.measure do
                begin
                  ActiveSupport::Dependencies.clear
                  logger.info "StateLoop: loading state: #{@next_state_name}"
                  @doc = context.run_state(@next_state_name, @next_state_params).output_as_json
                  logger.info "StateLoop: state loaded successfully: #{@next_state_name}"
                  @error = nil
                rescue Exception => e
                  logger.error "StateLoop: error while loading state: #{@next_state_name}"
                  logger.error e
                  @doc = nil
                  @error = e
                end
              end.real

              @lock.synchronize {
                @state_name = @next_state_name
                @state_params = @next_state_params
                @working = false
              }
            else sleep 0.2 end
          end
        rescue Exception => e
          logger.fatal "StateLoop: unhandled exception!"
          logger.fatal e
        ensure
          context.release
        end
      end

      def logger
        Crabfarm.logger
      end
    end
  end
end
