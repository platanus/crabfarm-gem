require 'spec_helper'

describe Crabfarm::Context do

  let(:mod) {
    Module.new do
      class MockState < Crabfarm::BaseState
      end

      class MockParser < Crabfarm::BaseParser
      end
    end
  }

  let(:config) { Crabfarm::Configuration.new }

  let(:helper) { Crabfarm::ModuleHelper.new mod, config }

  describe "load_state" do

    it "should return a state class with the given name" do
      expect(helper.load_state(:mock_state)).to be(mod.const_get(:MockState))
    end

    it "should fail if a class with the given name does not exist" do
      expect { helper.load_state(:unexistant) }.to raise_error(Crabfarm::EntityNotFoundError)
    end

    it "should fail if a class with the given name is not a state" do
      expect { helper.load_state(:mock_parser) }.to raise_error(Crabfarm::EntityNotFoundError)
    end

  end

  describe "load_parser" do

    it "should return a parser class with the given name" do
      expect(helper.load_parser(:mock_parser)).to be(mod.const_get(:MockParser))
    end

    it "should fail if a class with the given name does not exist" do
      expect { helper.load_parser(:unexistant) }.to raise_error(Crabfarm::EntityNotFoundError)
    end

    it "should fail if a class with the given name is not a parser" do
      expect { helper.load_parser(:mock_state) }.to raise_error(Crabfarm::EntityNotFoundError)
    end
  end

end
