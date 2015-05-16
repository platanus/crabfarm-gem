module Crabfarm
  module RSpec

    class Error < Crabfarm::Error; end

    def navigate(_name=nil, _params={})

      raise Error.new "'navigate' is only available in navigator specs" if @context.nil?

      if _name.is_a? Hash
        _params = _name
        _name = nil
      end

      if _name.nil?
        return nil unless described_class < BaseNavigator # TODO: maybe raise an error here.
        @state = @last_state = TransitionService.transition @context, described_class, _params
      else
        @last_state = TransitionService.transition @context, _name, _params
      end
    end

    def state
      @state ||= navigate
    end

    def last_state
      @last_state
    end

    def reduce(_snapshot, _params={})
      raise Error.new "'reduce' is only available in reducer specs" unless described_class < Crabfarm::BaseReducer
      raise Error.new 'Must provide a snapshot for reducer specs' if _snapshot.nil?

      snap_path = described_class.snapshot_path _snapshot
      raise Crabfarm::ArgumentError.new "Snapshot does not exist #{snap_path}" unless File.exist? snap_path

      reducer = Factories::SnapshotReducer.build described_class, snap_path, _params
      reducer.run
      reducer
    end

    def reducer
      @reducer ||= reduce(@reducer_snapshot, @reducer_params)
    end

    def browser(_session_id=nil)
      @context.pool.driver(_session_id)
    end

    def try_reducer
      @reducer
    end

    def try_state
      @state
    end
  end
end

RSpec.configure do |config|
  config.include Crabfarm::RSpec

  config.around(:example) do |example|

    if described_class < Crabfarm::BaseReducer
      @reducer_snapshot = example.metadata[:reducing]
      @reducer_params = example[:reducing_with_params] || {}

      begin
        example.run
      ensure
        if try_reducer
          # store result in metadata so it can be accessed by formatters/reporters
          example.metadata[:result] = try_reducer.as_json
        end
      end
    elsif described_class < Crabfarm::BaseNavigator
      Crabfarm.with_context example.metadata[:navigating] do |ctx|
        @context = ctx

        begin
          example.run
        ensure
          if try_state
            # store result in metadata so it can be accessed by formatters/reporters
            example.metadata[:result] = try_state.document
          end
        end
      end
    else
      example.run
    end
  end

end
