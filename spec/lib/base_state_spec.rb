require 'spec_helper'

describe Crabfarm::BaseState do

  before {
    Crabfarm.config.set_browser_dsl :fake_dsl_1
    Crabfarm.config.set_driver :noop # prevent phantomjs from starting
  }

  let(:fake_context) { Class.new {
      def pool
        Crabfarm::DriverBucketPool.new
      end
    }.new
  }

  let(:state_class_a) { Class.new(Crabfarm::BaseState) }
  let(:state_class_b) { Class.new(Crabfarm::BaseState) { browser_dsl :fake_dsl_2 } }

  let(:state_a) { state_class_a.new fake_context, { arg: 'imateapot' } }
  let(:state_b) { state_class_b.new fake_context, { } }

  describe "browser" do

    it 'should provide the dsl specified in context' do
      expect(state_a.browser.class).to be(FakeBrowserDsl1)
    end

    it "should provide the dsl specified in state definition over context's" do
      expect(state_b.browser.class).to be(FakeBrowserDsl2)
    end

  end

  describe "output" do

    it "should expose a hash object by default" do
      expect(state_a.output).to be_instance_of(Hash)
    end

  end

  describe "parse" do

    let(:state) { MockStateA.new fake_context, { arg: 'imateapot' } }
    let(:parser) { state.parse 'data', using: FakeParser, other_arg: 'param' }

    it "should load parser specified in :using" do
      expect(parser).to be_instance_of FakeParser
    end

    it "should pass the first argument to the parser as the target" do
      expect(parser.target).to eq('data')
    end

    it "should pass the named arguments to the parser as the params" do
      expect(parser.params[:arg]).to eq('imateapot')
      expect(parser.params[:other_arg]).to eq('param')
      expect(parser.params[:using]).to be_nil
    end

    it "should infer the parser name from the state name if :using is not given" do
      expect(state.parse 'data').to be_instance_of MockStateAParser
    end

  end

  describe "parse_*" do

    it "should call parse with the given target and params" do
      expect(state_a).to receive(:parse) { nil }.with('data', { using: FakeParser, other_arg: 'imateapot' })
      state_a.parse_fake 'data', other_arg: 'imateapot'
    end

  end

  describe "fork_each" do

    let(:state) { MockStateA.new fake_context, {} }

    it "should execute given block in paralell and wait for every thread to finish" do
      state.output[:values] = []
      state.fork_each(5.times) do |value|
        sleep (10.0 - value) / 10.0
        lock_output { |o| o[:values] << value }
      end
      expect(state.output[:values]).to eq([4,3,2,1,0])
    end

    it "should provide same access to parsers as parent state" do
      parser1, parser2 = nil, nil
      state.fork_each(1.times) do |value|
        parser1 = parse 'data'
        parser2 = parse_fake 'data'
      end

      expect(parser1).to be_instance_of MockStateAParser
      expect(parser2).to be_instance_of FakeParser
    end

  end
end
