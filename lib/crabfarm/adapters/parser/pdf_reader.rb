require "pdf-reader"

module Crabfarm
  class PdfReaderAdapter
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
