class BtcStats < Crabfarm::BaseState

  def crawl
    browser.goto('https://www.btc-e.com/')

    if params[:coin] == 'ltc'
      browser.search('.pairs li a')[4].click
    end

    indicators = browser.parse :indicators
    output[:price] = indicators.btc_price
  end

end
