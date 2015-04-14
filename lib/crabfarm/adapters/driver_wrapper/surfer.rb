require 'crabfarm/dsl/surfer'

module Crabfarm
  module Adapters
    module DriverWrapper
      class Surfer
        def self.wrap(_driver)
          Crabfarm::Dsl::Surfer::SurfContext.new _driver
        end
      end
    end
  end
end
