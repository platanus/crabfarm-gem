require 'rspec'

module Crabfarm
  module Utils
    module RSpecRunner
      extend self

      class SilentFormatter
        ::RSpec::Core::Formatters.register self

        def initialize(_output)
        end
      end

      class DummyOptions
        def configure(_); end
      end

      def run_spec_for(_target, _filter=nil)

        _target = Array(_target)
        # TODO: check target exist?

        first_time_config

        begin
          ::RSpec.configuration.files_or_directories_to_run = _target
          ::RSpec.configuration.inclusion_filter = _filter if _filter

          runner = ::RSpec::Core::Runner.new DummyOptions.new
          runner.run $stderr, $stdout

          ::RSpec.world.example_groups.map { |g| g.filtered_examples }.flatten
        ensure
          ::RSpec.clear_examples
        end
      end

    private

      def first_time_config
        unless @ready
          options = ::RSpec::Core::ConfigurationOptions.new [
            '-f','Crabfarm::Utils::RSpecRunner::SilentFormatter'
          ]

          options.configure ::RSpec.configuration
          @ready = true
        end
      end

    end
  end
end