require 'spec_helper'

describe Crabfarm::TransitionService do

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

  describe "apply_state" do

    it "should load and call crawl on the loaded state" do
      state = Crabfarm::TransitionService.apply_state context, mock_class
      expect(state.crawl_called).to be(true)
    end
  end

end
