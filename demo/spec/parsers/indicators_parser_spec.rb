require 'spec_helper'

describe IndicatorsParser do

  it "should extract bitcoin value from page header", parsing: 'btce.htm' do
    expect(parser.btc_price).to eq(326.5)
  end

end
