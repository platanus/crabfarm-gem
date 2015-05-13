class Watir::Browser
  def to_html
    html
  end

  def webdriver_elements
    []
  end
end

class Watir::Element
  def to_html
    html
  end

  def webdriver_elements
    if @element then [@element] else [] end
  end

end

class Watir::ElementCollection
  def to_html
    self.map(&:html).join
  end

  def webdriver_elements
    elements
  end
end

module Crabfarm
  module Adapters
    module DriverWrapper
      class Watir
        def self.wrap(_driver)
          ::Watir::Browser.new _driver
        end
      end
    end
  end
end
