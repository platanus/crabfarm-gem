class IndicatorsReducer < Crabfarm::BaseReducer

  attr_accessor :btc_price

  def run
    @btc_price = assert(at_css('.orderStats')).is_f greater_than: 0.0
  end

end

