require 'spec_helper'
require 'crabfarm/adapters/browser/noop'

describe Crabfarm::BaseNavigator do

  let(:fake_context) { Class.new {
      def pool
        Crabfarm::DriverPool.new Crabfarm::Adapters::Browser::Noop.new
      end
    }.new
  }

  let(:nav_class) { Class.new(Crabfarm::BaseNavigator) }
  let(:nav) { nav_class.new fake_context, { arg: 'imateapot' } }

  describe "browser" do

    it 'should provide the specified driver' do
      expect(nav.browser).to be(:default_driver)
    end

  end

  describe "output" do

    it "should expose a hash object by default" do
      expect(nav.output).to be_instance_of(Hash)
    end

  end

  describe "reduce" do

    let(:nav) { MockNavigatorA.new fake_context, { arg: 'imateapot' } }
    let(:reducer) { nav.reduce 'data', using: FakeReducer, other_arg: 'param' }

    it "should load reducer specified in :using" do
      expect(reducer).to be_instance_of FakeReducer
    end

    it "should load reducer specified in :using as string or symbol" do
      expect(nav.reduce 'data', using: :fake).to be_instance_of FakeReducer
    end

    it "should pass the first argument to the reducer as the target" do
      expect(reducer.target).to eq('data')
    end

    it "should pass the named arguments to the reducer as the params" do
      expect(reducer.params[:arg]).to eq('imateapot')
      expect(reducer.params[:other_arg]).to eq('param')
      expect(reducer.params[:using]).to be_nil
    end

    it "should infer the reducer name from the navigator name if :using is not given" do
      expect(nav.reduce 'data').to be_instance_of MockNavigatorAReducer
    end

  end

  describe "fork_each" do

    let(:nav) { MockNavigatorA.new fake_context, {} }

    it "should execute given block in paralell and wait for every thread to finish" do
      nav.output[:values] = []
      nav.fork_each(5.times) do |value|
        sleep (10.0 - value) / 10.0
        lock_output { |o| o[:values] << value }
      end
      expect(nav.output[:values]).to eq([4,3,2,1,0])
    end

    it "should provide same access to reducers as parent nav" do
      reducer1, reducer2 = nil, nil
      nav.fork_each(1.times) do |value|
        reducer1 = reduce 'data'
        reducer2 = reduce 'data', using: :fake
      end

      expect(reducer1).to be_instance_of MockNavigatorAReducer
      expect(reducer2).to be_instance_of FakeReducer
    end

  end
end
