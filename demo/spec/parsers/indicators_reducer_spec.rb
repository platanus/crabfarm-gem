require 'spec_helper'

describe IndicatorsReducer do

  it "should extract bitcoin value from page header", reducing: 'btce' do
    expect(reducer.btc_price).to eq(221.176)
  end

end
