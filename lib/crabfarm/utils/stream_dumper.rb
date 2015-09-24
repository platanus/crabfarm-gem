require 'thwait'

module Crabfarm::Utils

  class StreamDumper

    class Reload < StandardError; end

    def self.consumer
      @@consumer ||= self.new
    end

    def self.register_stream(_stream, &_block)
      consumer.register_stream _stream, &_block
      consumer.restart
    end

    def initialize
      @streams = []
      @lock = Mutex.new
      @worker = nil
    end

    def register_stream(_stream, &_block)
      @lock.synchronize { @streams << Wrapper.new(_stream, _block) }
    end

    def restart
      @lock.synchronize do
        if @worker and @worker.alive?
          @worker.raise Reload # signal worker to reload streams
        else
          @worker = load_worker
        end
      end
    end

  private

    def load_worker
      Thread.new do
        looped = 0
        begin
          while @streams.count > 0
            all_streams = dump_streams
            result = IO.select(all_streams << $stdin, [], all_streams)
            if result
              process_ready_streams result[0]
              discard_errored_streams result[2]
            end
            looped += 1
          end
        rescue Reload
          retry
        rescue SystemExit
          # nothing
        end
      end
    end

    def process_ready_streams(_streams)
      _streams.each do |stream|
        wrapper = find_stream_wrapper stream
        if wrapper
          wrapper.process_lines
          remove_wrapper wrapper, :eof if wrapper.eof?
        end
      end
    end

    def discard_errored_streams(_streams)
      _streams.each do |stream|
        wrapper = find_stream_wrapper stream
        remove_wrapper wrapper, :error if wrapper
      end
    end

    def find_stream_wrapper(_stream)
      @streams.find { |s| s.stream == _stream }
    end

    def remove_wrapper(_wrapper, _reason)
      @lock.synchronize { @streams.delete _wrapper }
    end

    def dump_streams
      @streams.map(&:stream)
    end

    class Wrapper

      MAX_LENGTH = 2048

      attr_reader :stream

      def initialize(_stream, _block)
        @stream = _stream
        @block = _block
        @buffer = []
        @eof = false
      end

      def eof?
        @eof
      end

      def process_lines
        begin
          loop do
            chunk = @stream.read_nonblock(MAX_LENGTH)
            process_chunk chunk
          end
        rescue IO::WaitReadable
          # nothing, just stop looping
        rescue EOFError
          @eof = true
        rescue Exception => exc
          puts "Error in stream consumer: #{exc}"
          @eof = true
        end
      end

      def process_chunk(_chunk)
        index = _chunk.index $/

        unless index.nil?
          head = _chunk[0..index-1]
          tail = _chunk[index+1..-1]

          @block.call(@buffer.join + head)
          @buffer.clear

          process_chunk tail
        else
          @buffer << _chunk
        end
      end

    end

  end
end