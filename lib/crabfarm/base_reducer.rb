require 'crabfarm/base'
require 'crabfarm/assertion/fields'
require 'crabfarm/live/interactable'

module Crabfarm
  class BaseReducer < Delegator
    include Base
    include Assertion::Fields
    include Live::Interactable

    attr_reader :raw_document, :document, :params

    def self.use_parser(_parser_name)
      @parser_name = _parser_name
    end

    def self.parser
      @parser ||= Strategies.load(:parser, @parser_name || Crabfarm.config.parser)
    end

    def self.snapshot_path(_name=nil)
      _name = self.to_s.underscore if _name.nil?
      Utils::Resolve.snapshot_path _name, parser.format
    end

    def parser
      self.class.parser
    end

    def initialize(_target, _params)
      reset_fields

      @raw_document = parser.preprocess_parsing_target _target
      @document = parser.parse @raw_document
      @params = _params

      super @document
    end

    def run
      raise NotImplementedError.new
    end

    def to_json(_options=nil)
      field_hash.to_json _options
    end

    def __getobj__
      @document
    end

    def __setobj__(obj)
      @document = obj
    end

  end
end
