require 'spec_helper'

describe Crabfarm::StateStore do

  let(:store) { described_class.new }

  describe "set" do
    it { expect { store.set(:some_key) }.not_to raise_error }
  end

  describe "is?" do
    it { expect(store.is?(:some_key)).to be false }
  end

  context "given some set keys" do

    before {
      store.set :flag
      store.set :foo, :bar
    }

    describe "is?" do\
      it { expect(store.is?(:flag)).to be true }
      it { expect(store.is?(:foo)).to be true }
    end
  end

end
