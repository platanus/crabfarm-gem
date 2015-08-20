require 'spec_helper'

describe BtcStats do

  let!(:reducer) { spy_reducer(:indicators).mock_with({ price: 0 }) }

  it "should navigate to btc page by default", navigating: 'btce' do
    navigate
    expect(browser.text).to include('Buy BTC');
  end

  it "should navigate to a alt coin page", navigating: 'btce-2' do
    navigate coin: 'ltc'
    expect(browser.text).to include('Buy LTC')
  end

end
