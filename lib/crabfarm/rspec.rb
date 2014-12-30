CF_LOADER.load

CF_TEST_CONTEXT = CF_LOADER.load_context
CF_TEST_BUCKET = CF_TEST_CONTEXT.driver

module Crabfarm
  module RSpec

    def parse(_snap_or_url, _options={})
      fixture = Pathname.new(File.join(ENV['SNAPSHOT_DIR'], _snap_or_url))
      if fixture.exist?
        CF_TEST_BUCKET.get("file://#{fixture.realpath}")
      else
        CF_TEST_BUCKET.get(_snap_or_url)
      end

      CF_TEST_BUCKET.parse(described_class, _options)
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
  end

  config.after(:suite) do
    CF_TEST_CONTEXT.release
  end
end
