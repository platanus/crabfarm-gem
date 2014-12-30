require 'spec_helper'

describe Crabfarm::Context do

  let(:helper) { Crabfarm::ModuleHelper.new Crabfarm::Mock }

  describe "load_state" do

    it "should return a state class with the given name" do
      expect(helper.load_state(:state)).to be(Crabfarm::Mock::State)
      expect(helper.load_state(:other_state)).to be(Crabfarm::Mock::OtherState)
    end

    it "should fail if a class with the given name does not exist" do
      expect { helper.load_state(:unexistant) }.to raise_error(Crabfarm::EntityNotFoundError)
    end

    it "should fail if a class with the given name is not a state" do
      expect { helper.load_state(:parser) }.to raise_error(Crabfarm::EntityNotFoundError)
    end

  end

  describe "load_parser" do

    it "should return a parser class with the given name" do
      expect(helper.load_parser(:parser)).to be(Crabfarm::Mock::Parser)
      expect(helper.load_parser(:other_parser)).to be(Crabfarm::Mock::OtherParser)
    end

    it "should fail if a class with the given name does not exist" do
      expect { helper.load_parser(:unexistant) }.to raise_error(Crabfarm::EntityNotFoundError)
    end

    it "should fail if a class with the given name is not a parser" do
      expect { helper.load_parser(:state) }.to raise_error(Crabfarm::EntityNotFoundError)
    end
  end

end
