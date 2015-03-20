require 'spec_helper'
require 'crabfarm/assertion/context'

describe Crabfarm::Assertion::Context do

  let(:ctx) {
    Class.new do
      include Crabfarm::Assertion::Context
    end.new
  }

  describe "assert" do

    describe "when given valid values" do
      it { expect(ctx.assert('10').is_i).to eq(10) }
      it { expect(ctx.assert('10.005 BTC').is_f).to eq(10.005) }
      it { expect(ctx.assert('10,000.10').is_i).to eq(10000) }
      it { expect(ctx.assert('  im a   teapot').is_s).to eq('im a teapot') }
      it { expect(ctx.assert('  teapot').is_w).to eq('teapot') }
      it { expect(ctx.assert('true').is_b).to eq(true) }
    end

    describe "when given invalid values" do
      it { expect { ctx.assert('hello').is_i }.to raise_error Crabfarm::AssertionError }
      it { expect { ctx.assert('10').is_i greater_than: 20 }.to raise_error Crabfarm::AssertionError }
      it { expect { ctx.assert('hello world').is_w }.to raise_error Crabfarm::AssertionError }
      it { expect { ctx.assert(nil).is_s }.to raise_error Crabfarm::AssertionError }
      it { expect { ctx.assert('bar').matches(/foo/) }.to raise_error Crabfarm::AssertionError }
    end

  end

end