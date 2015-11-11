require 'crabfarm/rspec/navigator_spec_helpers'
require 'crabfarm/rspec/reducer_spec_helpers'
require 'active_support/dependencies'

ActiveSupport::Dependencies.autoload_paths += Dir.glob File.join(CF_PATH, 'app', '**')

RSpec.configure do |config|
  config.include Crabfarm::RSpec::NavigatorSpecHelpers
  config.include Crabfarm::RSpec::ReducerSpecHelpers

  config.around(:example) do |example|
    if described_class < Crabfarm::BaseReducer
      @reducer_snapshot = example.metadata[:reducing]
      @reducer_params = example.metadata[:with_params] || {}

      begin
        example.run
      ensure
        # store result in metadata so it can be accessed by formatters/reporters
        example.metadata[:result] = @reducer_state if @reducer_state
      end
    elsif described_class < Crabfarm::BaseNavigator
      Crabfarm.with_context example.metadata[:navigating] do |ctx|
        @navigator_context = ctx
        @navigator_params = (example.metadata[:with_params] || {})

        begin
          example.run
        ensure
          # store result in metadata so it can be accessed by formatters/reporters
          example.metadata[:result] = @navigator_state.document if @navigator_state
        end
      end
    else
      example.run
    end
  end

end
