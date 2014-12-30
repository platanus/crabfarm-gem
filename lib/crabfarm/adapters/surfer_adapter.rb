module Crabfarm::Adapters
  class SurferAdapter
    def self.wrap(_bucket)
      Crabfarm::Dsl::Surfer::SurfContext.new _bucket
    end
  end
end
