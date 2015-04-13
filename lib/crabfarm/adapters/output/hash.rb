module Crabfarm
  module Adapters
    module Output
      class Hash
        def self.prepare
          ::Hash.new
        end

        def self.serialize(_output)
          _output
        end
      end
    end
  end
end
