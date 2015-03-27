require 'spec_helper'

describe IndicatorsParser do

  it "should extract bitcoin value from page header", parsing: 'btce' do
    expect(parser.btc_price).to eq(221.176)
  end

end
