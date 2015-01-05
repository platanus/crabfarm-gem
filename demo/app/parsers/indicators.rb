class Indicators < Crabfarm::BaseParser

  attr_accessor :btc_price

  def parse
    @btc_price = search('.orderStats').text.gsub(/[^\d\.]/, '').to_f
  end

end

