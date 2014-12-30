module Crabfarm::Adapters
  class WatirAdapter
    def self.wrap(_bucket)
      Watir::Browser.new _bucket.original
    end
  end
end
