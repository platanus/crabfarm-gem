require 'watir-webdriver'

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
  class WatirBrowserDsl
    def self.wrap(_bucket)
      Watir::Browser.new _bucket.original
    end
  end
end
