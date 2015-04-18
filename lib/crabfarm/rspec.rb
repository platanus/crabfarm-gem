module Crabfarm
  module RSpec

    class Error < Crabfarm::Error; end

    def reduce(_snapshot=nil, _options={})

      raise Error.new "'reduce' is only available in reducer specs" unless described_class < Crabfarm::BaseReducer

      if _snapshot.is_a? Hash
        raise ArgumentException.new 'Invalid arguments' unless _options.nil?
        _options = _snapshot
        _snapshot = nil
      end

      snapshot_path = described_class.snapshot_path _snapshot
      raise Error.new "Snapshot does not exist #{snapshot_path}" unless File.exist? snapshot_path

      data = File.read snapshot_path
      reducer = described_class.new data, _options
      reducer.run
      reducer
    end

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

    def reducer
      @reducer ||= reduce
    end

    def browser(_session_id=nil)
      @context.pool.driver(_session_id)
    end

  end
end

RSpec.configure do |config|
  config.include Crabfarm::RSpec

  config.around(:example) do |example|
    if described_class < Crabfarm::BaseReducer
      if example.metadata[:reducing] || example[:reducing_with_params]
        @reducer = reduce example.metadata[:reducing], example.metadata[:reducing_with_params] || {}
      end
      example.run
    elsif described_class < Crabfarm::BaseNavigator
      Crabfarm::ContextFactory.with_context example.metadata[:navigating] do |ctx|
        @context = ctx
        example.run
      end
    else
      example.run
    end
  end

end
