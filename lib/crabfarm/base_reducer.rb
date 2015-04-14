require "crabfarm/assertion/context"

module Crabfarm
  class BaseReducer < Delegator
    include Assertion::Context

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

      raise ArgumentError.new "Snapshot already exists '#{file_path}', make sure to implement the #{self.class.to_s} run method." if File.exist? file_path

      dir_path = file_path.split(File::SEPARATOR)[0...-1]
      FileUtils.mkpath dir_path.join(File::SEPARATOR) if dir_path.length > 0

      File.write file_path, @parsed_data
      nil
    end

    def __getobj__
      @document
    end

    def __setobj__(obj)
      @document = obj
    end

  end
end
