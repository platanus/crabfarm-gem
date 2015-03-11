module Crabfarm
  class ParserService

    def self.parse(_parser_class, _html, _options={})
      _parser_class = LoaderService.load_parser(_parser_class) if _parser_class.is_a? String or _parser_class.is_a? Symbol
      parser = _parser_class.new _html, _options
      parser.parse
      parser
    end

  end
end
