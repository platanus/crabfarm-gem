require 'spec_helper'

describe Crabfarm::BaseState do

  let(:env) { Surimi.build_fake_env }
  let(:pool) { Crabfarm::DriverBucketPool.new env }

  let(:state_class_a) { Class.new(Crabfarm::BaseState) }
  let(:state_class_b) { Class.new(Crabfarm::BaseState) { browser_dsl :surimi_2 } }

  let(:state_a) { state_class_a.new env, pool, nil, { arg: 'imateapot' } }
  let(:state_b) { state_class_b.new env, pool, nil, { } }

  describe "browser" do
    it 'should provide the dsl specified in context' do
      expect(state_a.browser.class).to be(Surimi::DslAdapter)
    end

    it "should provide the dsl specified in state definition over context's" do
      expect(state_b.browser.class).to be(Surimi::DslAdapter2)
    end
  end

  describe "output" do

    it "should expose a Jbuilder object" do
      expect(state_a.output).to be_instance_of(Jbuilder)
    end

  end
end
