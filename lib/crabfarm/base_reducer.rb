require "crabfarm/assertion/fields"

module Crabfarm
  class BaseReducer < Delegator
    include Assertion::Fields

    attr_reader :params, :document

    def self.use_parser(_parser_name)
      @parser_name = _parser_name
    end

    def self.parser
      @parser ||= Strategies.load(:parser, @parser_name || Crabfarm.config.parser)
    end

    def self.snapshot_path(_name=nil)
      _name = self.to_s.underscore if _name.nil?
      File.join(GlobalState.snapshots_path, _name + '.' + parser.format)
    end

    def parser
      self.class.parser
    end

    def initialize(_target, _params)
      reset_fields

      @parsed_data = parser.preprocess_parsing_target _target
      @document = parser.parse @parsed_data
      @params = _params

      super @document
    end

    def run
      raise NotImplementedError.new
    end

    def take_snapshot(_name=nil)
      file_path = self.class.snapshot_path _name

      dir_path = file_path.split(File::SEPARATOR)[0...-1]
      FileUtils.mkpath dir_path.join(File::SEPARATOR) if dir_path.length > 0

      File.write file_path, @parsed_data
      file_path
    end

    def take_snapshot_and_fail(_name=nil)
      file_path = take_snapshot _name
      raise ArgumentError.new "New snapshot for #{self.class.to_s} generated in '#{file_path}'"
    end

    def as_json(_options=nil)
      field_hash
    end

    def __getobj__
      @document
    end

    def __setobj__(obj)
      @document = obj
    end

  end
end
