require 'watir-webdriver'

class Watir::Browser
  def parse(_parser_class, _options={})
    Crabfarm::ParserService.parse _parser_class, html, _options
  end
end

class Watir::Element
  def parse(_parser_class, _options={})
    Crabfarm::ParserService.parse _parser_class, html, _options
  end
end

class Watir::ElementCollection
  def parse(_parser_class, _options={})
    full_html = self.map(&:html).join
    Crabfarm::ParserService.parse _parser_class, full_html, _options
  end
end

module Crabfarm
  class WatirBrowserDsl
    def self.wrap(_bucket)
      Watir::Browser.new _bucket.original
    end
  end
end
