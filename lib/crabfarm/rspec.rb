module Crabfarm
  module RSpec

    class Error < Crabfarm::Error; end

    def parse(_snapshot=nil, _options={})

      raise Error.new "Crawl is only available in parser specs" unless described_class < Crabfarm::BaseParser

      if _snapshot.is_a? Hash
        raise ArgumentException.new 'Invalid arguments' unless _options.nil?
        _options = _snapshot
        _snapshot = nil
      end

      snapshot_path = described_class.snapshot_path _snapshot
      raise Error.new "Snapshot does not exist #{_snapshot}" unless File.exist? snapshot_path

      data = File.read snapshot_path
      parser = described_class.new data, _options
      parser.parse
      parser
    end

    def crawl(_state=nil, _params={})

      raise Error.new "Crawl is only available in state specs" if @context.nil?

      if _state.is_a? Hash
        _params = _state
        _state = nil
      end

      if _state.nil?
        return nil unless described_class < BaseState # TODO: maybe raise an error here.
        @state = @last_state = TransitionService.apply_state @context, described_class, _params
      else
        @last_state = TransitionService.apply_state @context, _state, _params
      end
    end

    def state
      @state ||= crawl
    end

    def last_state
      @last_state
    end

    def parser
      @parser ||= parse
    end

    def driver(_session_id=nil)
      @context.pool.driver(_session_id)
    end

  end
end

RSpec.configure do |config|
  config.include Crabfarm::RSpec

  config.around(:example) do |example|
    if described_class < Crabfarm::BaseParser
      if example.metadata[:parsing] || example[:parsing_with_params]
        @parser = parse example.metadata[:parsing], example.metadata[:parsing_with_params] || {}
      end
      example.run
    elsif described_class < Crabfarm::BaseState
      Crabfarm::ContextFactory.with_context example.metadata[:crawling] do |ctx|
        @context = ctx
        example.run
      end
    else
      example.run
    end
  end

end
