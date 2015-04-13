require 'spec_helper'
require 'crabfarm/adapters/drivers/noop'

describe Crabfarm::DriverPool do

  before {
    Crabfarm.config.set_driver :noop
  }

  let(:pool) { Crabfarm::DriverPool.new Crabfarm::Adapters::Drivers::Noop.new }

  describe "driver" do

    it "should return the proper driver type" do
      expect(pool.driver).to be(:default_driver)
    end

    it "should return the same bucket if called twice with the same id" do
      expect(pool.driver(:hello)).to be(pool.driver(:hello))
      expect(pool.driver(:bye)).not_to be(pool.driver(:hello))
      expect(pool.driver).not_to be(pool.driver(:hello))
    end

  end

end
