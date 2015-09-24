class IndicatorsReducer < Crabfarm::BaseReducer

  has_float :price, greater_than: 0.0

  def run
    self.price = document.search('.orderStats:first')
  end

end
