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
      end
    end
  }

  let(:context) { Crabfarm::Context.new }

  describe "change_state" do

    it "should load and call run on the loaded navigator" do
      state = Crabfarm::TransitionService.transition context, mock_class
      expect(state.run_called).to be(true)
    end
  end

end
