require 'watir-webdriver'

module Crabfarm
  class WatirBrowserDsl
    def self.wrap(_bucket)
      Watir::Browser.new _bucket.original
    end
  end
end
