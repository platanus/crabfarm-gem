require 'spec_helper'

describe Crabfarm::Context do

  let(:context) { Crabfarm::Context.new Crabfarm::Mock }

  describe "run_state" do

    it "should load and call crawl on the loaded state" do
      state = context.run_state(:state)
      expect(state.crawl_called).to be(true)
    end
  end

end
