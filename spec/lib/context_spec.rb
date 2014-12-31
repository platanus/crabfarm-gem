require 'spec_helper'

describe Crabfarm::Context do

  let(:mock_module) {
    Module.new do
      class MockState < Crabfarm::BaseState
        attr_accessor :crawl_called

        def crawl
          @crawl_called = true
        end
      end
    end
  }

  let(:env) { Surimi.build_fake_env mock_module }
  let(:context) { Crabfarm::Context.new env }

  describe "run_state" do

    it "should load and call crawl on the loaded state" do
      state = context.run_state(:mock_state)
      expect(state.crawl_called).to be(true)
    end
  end

end
