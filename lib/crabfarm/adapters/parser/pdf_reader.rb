module Crabfarm
  module Adapters
    module Parser
      class PdfReader
        def self.format
          'pdf'
        end

        def self.parse(_raw)
          PDF::Reader.new StringIO.new _raw
        end

        def self.preprocess_parsing_target(_target)
          _target
        end
      end
    end
  end
end