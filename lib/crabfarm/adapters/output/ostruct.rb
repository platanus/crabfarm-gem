require 'ostruct'

module Crabfarm
  module Adapters
    module Output
      class OStruct
        def self.prepare
          # TODO: maybe wrap open struct in a class that automatically generate other openstruct when nested properties are accessed
          OpenStruct.new
        end

        def self.serialize(_output)
          _output.to_h
        end
      end
    end
  end
end