class IndicatorsReducer < Crabfarm::BaseReducer

  has_float :price, greater_than: 0.0

  live delegate: BtcStats

  def run
    self.price = at_css('.orderStats')
  end

end

