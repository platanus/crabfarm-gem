module Crabfarm
  module Adapters
    module Browser
      class Capybara
        def self.wrap(_driver)
          raise NotImplementedError.new "Capybara adapter is not available yet"
        end
      end
    end
  end
end
