# Collection of fake structures
module Surimi

  class DslAdapter < Struct.new(:bucket)
    def self.wrap(_bucket)
      DslAdapter.new _bucket
    end
  end

  class DslAdapter2 < Struct.new(:bucket)
    def self.wrap(_bucket)
      DslAdapter2.new _bucket
    end
  end

end

Crabfarm::Strategies.register :browser_dsl, :surimi, Surimi::DslAdapter
Crabfarm::Strategies.register :browser_dsl, :surimi_2, Surimi::DslAdapter2
