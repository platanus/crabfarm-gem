require 'spec_helper'

describe Crabfarm::Context do

  before {
    Crabfarm.config.set_driver :noop
  }

  let(:mock_class) {
    Class.new(Crabfarm::BaseState) do
      attr_accessor :crawl_called

      def crawl
        @crawl_called = true
      end
    end
  }

  let(:context) { Crabfarm::Context.new }

  describe "run_state" do

    it "should load and call crawl on the loaded state" do
      state = context.run_state mock_class
      expect(state.crawl_called).to be(true)
    end
  end

end
