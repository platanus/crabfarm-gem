require 'listen'

module Crabfarm
  module Live
    class Watcher

      PATH_RGX = /^\/[^\/]+\/(.*?)\.rb$/i

      def initialize(_controller)
        @controller = _controller
        @candidates = nil
      end

      def watch(_sleep)
        begin
          start_listener
          loop do
            execute_pending
            sleep _sleep
          end
        ensure
          stop_listener
        end
      end

    private

      def start_listener
        base_path = File.join CF_PATH, 'app'
        @listener = Listen.to(base_path) do |modified, added, removed|
          @candidates = (added + modified).map do |path|
            class_from_path path[base_path.length..-1]
          end.reject &:nil?
        end
        @listener.start
      end

      def stop_listener
        @listener.stop if @listener
      end

      def execute_pending
        unless @candidates.nil?
          ActiveSupport::Dependencies.clear
          @candidates.each do |class_name|
            target = class_name.constantize rescue nil
            if target and target < Crabfarm::Live::Interactable
              @controller.execute_live target
              break
            end
          end

          @candidates = nil
        end
      end

      def class_from_path(_filename)
        _filename = _filename.gsub File::SEPARATOR, '/'
        m = _filename.match PATH_RGX
        return nil if m.nil?
        Utils::Naming.decode_crabfarm_uri m[1]
      end

    end

  end
end
