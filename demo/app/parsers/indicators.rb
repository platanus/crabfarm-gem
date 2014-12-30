class Indicators < Crabfarm::BaseParser

  attr_accessor :btc_price

  def parse
    @btc_price = browser.search('.orderStats').text.gsub(/[^\d\.]/, '').to_f
  end

end

