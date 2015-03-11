require 'spec_helper'
require 'crabfarm/adapters/browser/watir'

describe Crabfarm::WatirBrowserDsl do

  before(:context) {
    @pool = Crabfarm::DriverBucketPool.new
  }

  after(:example) { @pool.reset }

  after(:context) { @pool.release }

  let(:browser) { Crabfarm::WatirBrowserDsl.wrap @pool.driver }

  context "when inside a simple page" do

    before { browser.goto "file://#{FIXTURE_PATH}/simple.html" }

    describe "parse" do

      before {
        Crabfarm.config.set_parser_dsl :surimi
      }

      let (:parser_class) { Class.new(Crabfarm::BaseParser) { def parse; end } }

      it "should load the parser html using the current node html" do
        expect(browser.parse(parser_class).root.html).to eq '<html><head></head><body><ul class="bikes"><li>GT</li><li>Mongoose</li></ul></body></html>'
        expect(browser.lis.parse(parser_class).root.html).to eq '<li>GT</li><li>Mongoose</li>'
        expect(browser.lis.first.parse(parser_class).root.html).to eq '<li>GT</li>'
      end
    end

  end
end
