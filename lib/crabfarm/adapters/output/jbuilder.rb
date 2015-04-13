module Crabfarm
  module Adapters
    module Output
      class Jbuilder
        def self.prepare
          Jbuilder.new
        end

        def self.serialize(_output)
          _output.attributes!
        end
      end
    end
  end
end