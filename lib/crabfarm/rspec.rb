require 'crabfarm/crabtrap_context'
require 'net/http'

CF_TEST_CONTEXT = Crabfarm::CrabtrapContext::new
CF_TEST_CONTEXT.load
CF_TEST_BUCKET = CF_TEST_CONTEXT.driver

module Crabfarm
  module RSpec

    def parse(_snap_or_url, _options={})
      fixture = Pathname.new(File.join(ENV['SNAPSHOT_DIR'], _snap_or_url))
      html = if fixture.exist?
        File.read fixture.realpath
      else
        Net::HTTP.get(URI.parse _snap_or_url)
      end

      ParserService.parse described_class, html, _options
    end

    def crawl(_state=nil, _params={})
      if _state.is_a? Hash
        _params = _state
        _state = nil
      end

      if _state.nil?
        return nil unless described_class < BaseState # TODO: maybe raise an error here.
        @state = @last_state = CF_TEST_CONTEXT.run_state(described_class, _params)
      else
        @last_state = CF_TEST_CONTEXT.run_state(_state, _params)
      end
    end

    def state
      @state ||= crawl
    end

    def last_state
      @last_state
    end

    def parser
      @parser
    end

  end
end

RSpec.configure do |config|
  config.include Crabfarm::RSpec

  config.before(:example) do |example|

    if example.metadata[:parsing]
      @parser = parse example.metadata[:parsing], example.metadata[:using] || {}
    end

    if example.metadata[:crawling]
      CF_TEST_CONTEXT.replay File.join(CF_PATH, 'spec/mementos', example.metadata[:crawling] + '.json.gz')
    else
      CF_TEST_CONTEXT.pass_through
    end
  end

  config.after(:suite) do
    CF_TEST_CONTEXT.release
  end
end
