require 'spec_helper'

describe Crabfarm::BaseParser do

  let(:mod) { Crabfarm::ModuleHelper.new Crabfarm::Mock }
  let(:driver) { Object.new }

  describe "browser" do
    it 'should provide a webdriver wrapped with the dsl specified in context' do
      dummy = Crabfarm::Mock::Parser.new mod, driver, {}
      expect(dummy.browser.class).to be(Crabfarm::Mock::MockAdapter)
    end

    it 'should provide a webdriver wrapped with the dsl specified in parser' do
      dummy = Crabfarm::Mock::OtherParser.new mod, driver, {}
      expect(dummy.browser.class).to be(Crabfarm::Mock::MockAdapter2)
    end
  end

  describe "params" do
    it 'should provide a access to external parameters' do
      dummy = Crabfarm::Mock::Parser.new mod, driver, { arg: 'imateapot' }
      expect(dummy.params[:arg]).to eq('imateapot')
    end
  end
end
