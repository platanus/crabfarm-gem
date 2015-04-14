require 'spec_helper'
require 'watir-webdriver'
require 'crabfarm/adapters/driver_wrapper/watir'

describe Crabfarm::Adapters::DriverWrapper::Watir do

  before(:context) {
    @driver = Selenium::WebDriver.for :phantomjs
  }

  after(:context) {
    @driver.quit rescue nil
  }

  let(:browser) { Crabfarm::Adapters::DriverWrapper::Watir.wrap @driver }

  context "when inside a simple page" do

    before { browser.goto "file://#{FIXTURE_PATH}/simple.html" }

    describe "to_html" do
      it "should load the parser html using the current node html" do
        expect(browser.to_html).to eq '<html><head></head><body><ul class="bikes"><li>GT</li><li>Mongoose</li></ul></body></html>'
        expect(browser.lis.to_html).to eq '<li>GT</li><li>Mongoose</li>'
        expect(browser.lis.first.to_html).to eq '<li>GT</li>'
      end
    end

  end
end
