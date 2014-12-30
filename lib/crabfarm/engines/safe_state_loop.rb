require 'ostruct'

module Crabfarm
  module Engines
    class SafeStateLoop

      def initialize(_loader)
        @context = _loader.load_context
        @running = true
        @working = false
        @lock = Mutex.new
        @thread = Thread.new { crawl_loop }
      end

      def release
        @running = false
        @thread.join
        @context.release
      end

      def change_state(_name, _params={}, _wait=nil)
        @lock.synchronize {
          raise StillWorkingError.new if @working
          @next_state_name = _name
          @next_state_params = _params
          @working = true

          wait_and_load_struct _wait
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
          doc: @doc
        })
      end

      def crawl_loop
        while @running
          if @working
            begin
              last_state = @context.run_state @next_state_name, @next_state_params
              @doc = last_state.output.attributes!
              @error = nil
            rescue Exception => e
              @doc = nil
              @error = e
            end

            @state_name = @next_state_name
            @state_params = @next_state_params
            @working = false
          else sleep 0.2 end
        end
      end
    end
  end
end
