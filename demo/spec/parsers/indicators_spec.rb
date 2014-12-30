require 'spec_helper'

describe Indicators do

  it "should extract bitcoin value from live page", parsing: 'https://btc-e.com/' do
    expect(parser.btc_price).to be_instance_of(Float)
  end

  it "should extract bitcoin value from snapshot", parsing: 'btce.htm' do
    expect(parser.btc_price).to eq(326.5)
  end

end
