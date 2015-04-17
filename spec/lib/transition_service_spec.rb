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

  describe "self.with_navigator_decorator" do
    it "should apply decorator on every generated navigator" do
      decorator = double('decorator')
      expect(decorator).to receive(:decorate).with(kind_of mock_class) { mock_class.new nil, nil }

      Crabfarm::TransitionService.with_navigator_decorator(decorator) do
        state.transition mock_class
      end
    end

    it "should apply chained decorators on generated navigators, from inner to outer scope" do
      mock_class_b = Class.new(Crabfarm::BaseNavigator) { def run; end }

      decorator_a = double('decorator_a')
      decorator_b = double('decorator_b')

      expect(decorator_a).to receive(:decorate).with(kind_of mock_class) { mock_class_b.new nil, nil }
      expect(decorator_b).to receive(:decorate).with(kind_of mock_class_b) { mock_class.new nil, nil }

      Crabfarm::TransitionService.with_navigator_decorator(decorator_b) do
        Crabfarm::TransitionService.with_navigator_decorator(decorator_a) do
          state.transition mock_class
        end
      end
    end
  end

end
