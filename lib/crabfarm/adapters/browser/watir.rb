class Watir::Browser
  def to_html
    html
  end
end

class Watir::Element
  def to_html
    html
  end
end

class Watir::ElementCollection
  def to_html
    self.map(&:html).join
  end
end

module Crabfarm
  module Adapters
    module Browser
      class Watir
        def self.wrap(_driver)
          ::Watir::Browser.new _driver
        end
      end
    end
  end
end
