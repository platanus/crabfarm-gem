require 'nokogiri'

module Crabfarm
  class NokogiriAdapter
    def self.format
      'html'
    end

    def self.parse(_raw)
      Nokogiri::HTML _raw
    end

    def self.preprocess_parsing_target(_target)
      if _target.respond_to? :to_html
        _target.to_html
      else
        _target
      end
    end
  end
end
