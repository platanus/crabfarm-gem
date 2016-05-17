require 'spec_helper'

describe Crabfarm::TransitionService do

  before {
    Crabfarm.config.set_browser :noop
  }

  let(:mock_class) {
    Class.new(Crabfarm::BaseNavigator) do
      attr_accessor :run_called

      def run
        @run_called = true
        :the_output
      end
    end
  }

  let(:context) { Crabfarm::Context.new }
  let(:state) { Crabfarm::TransitionService.new context }

  describe "transition" do
    it "should load and call run on the loaded navigator" do
      state.transition mock_class
      expect(state.navigator.run_called).to be(true)
    end
  end

  describe "document" do
    it "should expose the last transition output document" do
      state.transition mock_class
      expect(state.document).to eq :the_output
    end
  end
end
