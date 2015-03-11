require 'nokogiri'

module Crabfarm
  class NokogiriDsl
    def self.parse(_html)
      Nokogiri::HTML _html
    end
  end
end
