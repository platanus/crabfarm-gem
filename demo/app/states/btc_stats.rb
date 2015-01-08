class BtcStats < Crabfarm::BaseState

  def crawl
    browser.goto('https://www.btc-e.com/')
    indicators = browser.parse :indicators
    output[:price] = indicators.btc_price
  end

end
