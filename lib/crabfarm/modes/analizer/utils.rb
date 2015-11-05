require 'uri'

module Crabfarm
  module Modes
    module Analizer
      module Utils
        extend self

        URI_PARSER = URI::Parser.new(:UNRESERVED => URI::REGEXP::PATTERN::UNRESERVED + '|')

        def parse_uri(_url)
          URI_PARSER.parse _url
        end
      end
    end
  end
end