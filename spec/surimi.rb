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

  class ParserDsl < Struct.new(:html)
    def self.parse(_html)
      ParserDsl.new _html
    end
  end

  class ParserDsl2 < Struct.new(:html)
    def self.parse(_html)
      ParserDsl2.new _html
    end
  end

end

Crabfarm::Strategies.register :browser_dsl, :surimi, Surimi::DslAdapter
Crabfarm::Strategies.register :browser_dsl, :surimi_2, Surimi::DslAdapter2

Crabfarm::Strategies.register :parser_dsl, :surimi, Surimi::ParserDsl
Crabfarm::Strategies.register :parser_dsl, :surimi_2, Surimi::ParserDsl2
