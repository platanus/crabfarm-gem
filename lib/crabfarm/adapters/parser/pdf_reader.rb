require "pdf-reader"

module Crabfarm
  class PdfReaderAdapter
    def self.parse(_pdf_data)
      PDF::Reader.new StringIO.new _pdf_data
    end
  end
end
