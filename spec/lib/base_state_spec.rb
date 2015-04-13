require 'spec_helper'
require 'crabfarm/adapters/drivers/noop'

describe Crabfarm::BaseState do

  let(:fake_context) { Class.new {
      def pool
        Crabfarm::DriverPool.new Crabfarm::Adapters::Drivers::Noop.new
      end
    }.new
  }

  let(:state_class) { Class.new(Crabfarm::BaseState) }
  let(:state) { state_class.new fake_context, { arg: 'imateapot' } }

  describe "browser" do

    it 'should provide the specified driver' do
      expect(state.browser).to be(:default_driver)
    end

  end

  describe "output" do

    it "should expose a hash object by default" do
      expect(state.output).to be_instance_of(Hash)
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
      expect(state).to receive(:parse) { nil }.with('data', { using: FakeParser, other_arg: 'imateapot' })
      state.parse_fake 'data', other_arg: 'imateapot'
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
