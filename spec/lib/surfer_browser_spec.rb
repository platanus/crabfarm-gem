require 'spec_helper'
require 'crabfarm/dsl/surfer'

describe Crabfarm::Dsl::Surfer do

  before(:context) {
    env = Crabfarm::ModuleHelper.new nil, Crabfarm::Configuration.new
    @pool = Crabfarm::DriverBucketPool.new env
  }

  after(:example) { @pool.reset }

  after(:context) { @pool.release }

  let(:surfer) { Crabfarm::Dsl::Surfer::SurfContext.new @pool.driver }

  describe "goto" do

    it "should navigate to given url" do
      surfer.goto "http://platan.us"
      expect(surfer.current_uri.host).to eq('platan.us')
    end

  end

  context "when inside a page" do

    before { surfer.goto "file://#{FIXTURE_PATH}/surfer.html" }

    describe "search" do

      it "should use the given css to retrieve elements" do
        expect(surfer.search('ul.bikes li').count).to eq(3)
      end

      it "should return a new search context" do
        expect(surfer.search('ul li')).to be_a(Crabfarm::Dsl::Surfer::SearchContext)
      end

      it "should only search in parent context" do
        expect(surfer.search('ul.empty').search('li').count).to eq(0)
      end

      context "when :wait option is used" do

        pending "should wait a given condition if required"

        it "should fail with timout error if wait times out" do
          expect { surfer.search('.non-existant', wait: :present, timeout: 0.1) }.to raise_error(Crabfarm::Dsl::Surfer::WebdriverError)
        end

      end

    end

    describe "each" do
      it "should iterate over matching elements, wrapping each element in a new context" do
        count = 0
        surfer.search('ul.bikes li').each do |el|
          expect(el).to be_a(Crabfarm::Dsl::Surfer::SearchContext)
          count += 1
        end

        expect(count).to eq(3)
      end
    end

    describe "[]" do

      let(:result) { surfer.search('form input') }

      it "should return the element in position N wrapped in search context if numeric index is given" do
        expect(result[1]).to be_a(Crabfarm::Dsl::Surfer::SearchContext)
        expect(result[1].attribute(:type)).to eq('email')
      end

      it "should return the attribute named N of the first element if string is given" do
        expect(result[:type]).to eq('text')
      end

    end

    describe "classes" do
      it "should return every class the first element of the search has" do
        expect(surfer.search('p.description').classes).to eq(['history', 'description'])
      end
    end

    describe "text" do
      it "should return the text from the first of matched elements" do
        expect(surfer.search('ul.bikes li').text).to eq('GT')
      end
    end

  end
end