class Pincers::Core::SearchContext
  def webdriver_elements
    elements
  end
end

module Crabfarm
  module Adapters
    module DriverWrapper
      class Pincers
        def self.wrap(_driver)
          ::Pincers.for_webdriver _driver
        end
      end
    end
  end
end
