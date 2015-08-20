require 'rspec'

module Crabfarm
  module Utils
    module RSpecRunner
      extend self

      class SilentFormatter
        def initialize(_output)
          # do nothing with output (very silent!)
        end
      end

      def run_single_spec_for(_target, _tag=nil)
        setup_rspec_once

        begin
          configuration.reset

          runner = ::RSpec::Core::Runner.new config_options(_target)
          runner.setup $stderr, $stdout
          example = skip_all_but_one _tag
          runner.run_specs(world.ordered_example_groups)

          example
        ensure
          ::RSpec.clear_examples
        end
      end

    private

      def world
        ::RSpec.world
      end

      def configuration
        ::RSpec.configuration
      end

      def setup_rspec_once
        unless @ready
          ::RSpec::Core::Formatters.register SilentFormatter
          @ready = true
        end
      end

      def config_options(_target)
        ::RSpec::Core::ConfigurationOptions.new [
            _target,
            '-f','Crabfarm::Utils::RSpecRunner::SilentFormatter'
        ]
      end

      def skip_all_but_one(_tag)
        best_example = world.all_examples.inject(nil) do |best, example|
          example.metadata[:skip] = true
          if is_better_example? example, best, _tag
            example
          else
            best
          end
        end

        best_example.metadata[:skip] = false if best_example
        best_example
      end

      def is_better_example?(_new, _old, _tag)
        return true if _old.nil?

        new_tagged = !!(_new.metadata[_tag])
        old_tagged = !!(_old.metadata[_tag])

        # preffer tagged
        return new_tagged if new_tagged != old_tagged

        # preffer higher line number
        return _new.metadata[:line_number] > _old.metadata[:line_number]
      end

    end
  end
end