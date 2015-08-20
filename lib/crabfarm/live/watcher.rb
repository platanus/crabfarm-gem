require 'listen'
require 'crabfarm/utils/console'

module Crabfarm
  module Live
    class Watcher

      PATH_RGX = /^\/[^\/]+\/(.*?)\.rb$/i
      SPEC_RGX = /^\/[^\/]+\/(.*?)_spec\.rb$/i

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
        app_path = File.join CF_PATH, 'app'
        spec_path = File.join CF_PATH, 'spec'
        @listener = Listen.to(app_path, spec_path) do |modified, added, removed|
          @candidates = (added + modified).map do |path|
            if path.start_with? app_path
              class_from_path path[app_path.length..-1], PATH_RGX
            else
              class_from_path path[spec_path.length..-1], SPEC_RGX
            end
          end.reject(&:nil?)
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
            target = begin
              class_name.constantize
            rescue Exception => exc
              @controller.display_external_error exc
              nil
            end

            if target and target < Crabfarm::Live::Interactable
              if @thread and @thread.alive?
                @thread.terminate
                @thread.join
              end

              @thread = Thread.new { @controller.execute_live target }
              break
            end
          end

          @candidates = nil
        end
      end

      def class_from_path(_filename, _regexp)
        _filename = _filename.gsub File::SEPARATOR, '/'
        m = _filename.match _regexp
        return nil if m.nil?
        Utils::Naming.decode_crabfarm_uri m[1]
      end

    end

  end
end
