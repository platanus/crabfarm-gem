module Crabfarm
  class HashOutputBuilder
    def self.prepare
      Hash.new
    end

    def self.serialize(_output)
      _output
    end
  end
end
