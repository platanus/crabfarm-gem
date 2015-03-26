require 'spec_helper'

describe Crabfarm::Utils::Naming do

  let(:mod) { Crabfarm::Utils::Naming }

  describe "is_constant_name?" do
    it { expect(mod.is_constant_name? 'Simple').to be_truthy }
    it { expect(mod.is_constant_name? 'CompoundName').to be_truthy }
    it { expect(mod.is_constant_name? 'MyOwn::Namespaced::CompoundName').to be_truthy }
    it { expect(mod.is_constant_name? 'simple').to be_falsy }
    it { expect(mod.is_constant_name? 'Under_Scored').to be_falsy }
    it { expect(mod.is_constant_name? 'Namespaced::Under_Scored').to be_falsy }
  end

  describe "route_from_constant" do
    it { expect(mod.route_from_constant 'CompoundName').to eq ['compound_name'] }
    it { expect(mod.route_from_constant 'MyOwn::Namespaced::CompoundName').to eq ['my_own', 'namespaced', 'compound_name'] }
  end

  describe "decode_crabfarm_uri" do
    it { expect(mod.decode_crabfarm_uri 'simple').to eq 'Simple' }
    it { expect(mod.decode_crabfarm_uri 'compound_name').to eq 'CompoundName' }
    it { expect(mod.decode_crabfarm_uri 'my_own/namespaced/compound_name').to eq 'MyOwn::Namespaced::CompoundName' }
  end

end
