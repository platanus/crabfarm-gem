module Crabfarm
  module Mock
    CF_CONFIG = Configuration.new

    class MockAdapter
      def self.wrap(_bucket)
        MockAdapter.new
      end
    end

    class MockAdapter2
      def self.wrap(_bucket)
        MockAdapter2.new
      end
    end

    Crabfarm::Adapters.register_dsl :mock, MockAdapter
    Crabfarm::Adapters.register_dsl :mock2, MockAdapter2
    CF_CONFIG.default_dsl = :mock

    class FakeDriver
    end

    class FakeDriverFactory

      def self.build_driver(_session_id)
        FakeDriver.new
      end

    end

    CF_CONFIG.driver_factory = FakeDriverFactory

    class Parser < Crabfarm::BaseParser

      attr_reader :parse_called

      def parse
        @parse_called = true
      end

    end

    class OtherParser < Parser

      browser_dsl :mock2

    end

    class State < Crabfarm::BaseState

      attr_reader :crawl_called

      def crawl
        @crawl_called = true
      end

    end

    class OtherState < State

      browser_dsl :mock2

    end

  end
end
