class BtcStats < Crabfarm::BaseNavigator

  def run
    browser.goto('https://www.btc-e.com/')

    if params[:coin] == 'ltc'
      browser.search('.pairs li a')[4].click
    end

    reduce using: :indicators
  end

end
