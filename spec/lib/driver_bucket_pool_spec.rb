require 'spec_helper'

describe Crabfarm::DriverBucketPool do

  let(:env) { Surimi.build_fake_env }
  let(:pool) { Crabfarm::DriverBucketPool.new env }

  describe "driver" do

    it "should return a driver bucket that generates driver using the context's loader" do
      expect(pool.driver.original).to be_instance_of(Surimi::Driver)
    end

    it "should return the same bucket if called twice with the same id" do
      expect(pool.driver(:hello)).to be(pool.driver(:hello))
      expect(pool.driver(:bye)).not_to be(pool.driver(:hello))
      expect(pool.driver).not_to be(pool.driver(:hello))
    end

  end

end
