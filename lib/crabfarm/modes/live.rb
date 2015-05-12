require 'listen'
require 'crabfarm/live/controller'

module Crabfarm
  module Modes
    module Live
      extend self

      PATH_RGX = /^\/[^\/]+\/(.*?)\.rb$/i

      def class_from_path(_filename)
        _filename = _filename.gsub File::SEPARATOR, '/'
        m = _filename.match PATH_RGX
        return nil if m.nil?
        class_name = Utils::Naming.decode_crabfarm_uri m[1]
        class_name.constantize
      end

      def setup_watcher
        base_path = File.join CF_PATH, 'app'
        Listen.to(base_path) do |modified, added, removed|
          begin
            (added + modified).each do |path|
              target = class_from_path path[base_path.length..-1]
              if target and target < Crabfarm::Live::Interactable
                yield target
                break
              end
            end
          rescue Exception => e
            puts "#{e.class.to_s}: #{e.to_s}".color Console::Colors::ERROR
            puts e.backtrace
          end
        end
      end

      def start_watch
        begin
          @last_change = nil
          manager = Crabfarm.install_live_backend
          manager.start

          controller = Crabfarm::Live::Controller.new manager

          watcher = setup_watcher { |t| @last_change = t }
          watcher.start

          loop do
            unless @last_change.nil?
              ActiveSupport::Dependencies.clear
              controller.execute_live @last_change
              @last_change = nil
            else
              sleep 0.2
            end
          end
        rescue SystemExit, Interrupt
          # nothing
        rescue Exception => e
          puts "Fatal error: #{e.to_s}".color Console::Colors::ERROR
          puts e.backtrace
        ensure
          puts 'Exiting'
          manager.stop rescue nil
          watcher.stop rescue nil
        end
      end

    end
  end
end
