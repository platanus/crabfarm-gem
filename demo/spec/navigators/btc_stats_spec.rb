require 'spec_helper'

describe BtcStats do

  it "should extract the bitcoin value", navigating: 'btce' do
    expect(state.output[:price]).to eq(221.176);
  end

  it "should extract the litecoin value", navigating: 'btce-2' do
    expect(navigate(coin: 'ltc').output[:price]).to eq(0.0079);
  end

end
