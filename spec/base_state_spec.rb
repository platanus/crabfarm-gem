require 'spec_helper'

describe Crabfarm::BaseState do

  let(:mod) { Crabfarm::ModuleHelper.new Crabfarm::Mock }
  let(:pool) { Crabfarm::DriverBucketPool.new mod }
  let(:driver) { Object.new }

  describe "browser" do

    it 'should provide a webdriver wrapped with the dsl specified in context' do
      dummy = Crabfarm::Mock::State.new mod, pool, nil, {}
      expect(dummy.browser.class).to be(Crabfarm::Mock::MockAdapter)
    end

    it "should provide a webdriver wrapped with the dsl specified in state definition over context's" do
      dummy = Crabfarm::Mock::OtherState.new mod, pool, nil, {}
      expect(dummy.browser.class).to be(Crabfarm::Mock::MockAdapter2)
    end

  end

  describe "output" do

    it "should expose a Jbuilder object" do
      dummy = Crabfarm::Mock::OtherState.new mod, pool, nil, {}
      expect(dummy.output).to be_instance_of(Jbuilder)
    end

  end
end
