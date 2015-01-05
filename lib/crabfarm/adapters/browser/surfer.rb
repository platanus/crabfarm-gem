require 'crabfarm/dsl/surfer'

module Crabfarm
  class SurferBrowserDsl
    def self.wrap(_bucket)
      Crabfarm::Dsl::Surfer::SurfContext.new _bucket
    end
  end
end
