require 'spec_helper'

describe Crabfarm::BaseState do

  before {
    Crabfarm.config.set_browser_dsl :surimi
    Crabfarm.config.set_driver :noop # prevent phantomjs from starting
  }

  let(:pool) { Crabfarm::DriverBucketPool.new }

  let(:state_class_a) { Class.new(Crabfarm::BaseState) }
  let(:state_class_b) { Class.new(Crabfarm::BaseState) { browser_dsl :surimi_2 } }

  let(:state_a) { state_class_a.new pool, nil, { arg: 'imateapot' } }
  let(:state_b) { state_class_b.new pool, nil, { } }

  describe "browser" do
    it 'should provide the dsl specified in context' do
      expect(state_a.browser.class).to be(Surimi::DslAdapter)
    end

    it "should provide the dsl specified in state definition over context's" do
      expect(state_b.browser.class).to be(Surimi::DslAdapter2)
    end
  end

  describe "output" do

    it "should expose a hash object by default" do
      expect(state_a.output).to be_instance_of(Hash)
    end

  end

  describe "fork_each" do

    it "should execute given block in paralell and wait for every thread to finish" do
      state_a.output[:values] = []
      state_a.fork_each(5.times) do |value|
        sleep (10.0 - value) / 10.0
        lock_output { |o| o[:values] << value }
      end
      expect(state_a.output[:values]).to eq([4,3,2,1,0])
    end

  end
end
