class IndicatorsParser < Crabfarm::BaseParser

  attr_accessor :btc_price

  def parse
    @btc_price = at_css('.orderStats').text.gsub(/[^\d\.]/, '').to_f
  end

end

