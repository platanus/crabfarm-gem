require 'inquirer'
require 'crabfarm/modes/console'

module Crabfarm
  module Modes
    module Shared
      module SnapshotDecorator

        module Colors
          include Crabfarm::Modes::Console::Colors
        end

        def self.decorate(_reducer)
          loop do
            name = Ask.input "-- Name for #{_reducer.class.to_s} snapshot (blank to skip)".color Colors::QUESTION
            if name.empty?
              puts "-- Skipping snapshot".color Colors::WARNING
              break
            else
              file_path = _reducer.class.snapshot_path name

              if File.exist? file_path
                puts "-- Could not save snapshot, file already exist!".color Colors::ERROR
              else
                dir_path = file_path.split(File::SEPARATOR)[0...-1]
                FileUtils.mkpath dir_path.join(File::SEPARATOR) if dir_path.length > 0
                File.write file_path, _reducer.raw_document
                puts "-- Snapshot written to #{file_path}".color Colors::RESULT
                break
              end
            end
          end

          nil
        end

      end

    end
  end
end