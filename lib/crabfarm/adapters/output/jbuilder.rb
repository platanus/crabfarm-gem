module Crabfarm
  class JbuilderOutputBuilder
    def self.prepare
      Jbuilder.new
    end

    def self.serialize(_output)
      _output.attributes!
    end
  end
end
