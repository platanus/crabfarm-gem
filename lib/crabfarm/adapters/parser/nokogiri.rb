require 'nokogiri'

module Crabfarm
  class NokogiriAdapter
    def self.parse(_element)
      if _element.respond_to? :to_html
        Nokogiri::HTML _element.to_html
      else
        Nokogiri::HTML _element
      end
    end
  end
end
