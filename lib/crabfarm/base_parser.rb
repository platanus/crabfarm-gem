require "crabfarm/assertion/context"

module Crabfarm
  class BaseParser < Delegator
    include Assertion::Context

    attr_reader :params, :document

    def self.parser_engine(_engine=nil)
      @engine_name = _engine
    end

    def self.engine
      @engine ||= Strategies.load(:parser_engine, @engine_name || Crabfarm.config.parser_engine)
    end

    def self.snapshot_path(_name=nil)
      _name = self.to_s.underscore if _name.nil?
      File.join(GlobalState.snapshots_path, _name + '.' + engine.format)
    end

    def engine
      self.class.engine
    end

    def initialize(_target, _params)
      @parsed_data = engine.preprocess_parsing_target _target
      @document = engine.parse @parsed_data
      @params = _params

      super @document
    end

    def parse
      raise NotImplementedError.new
    end

    def take_snapshot(_name=nil)
      file_path = self.class.snapshot_path _name

      raise ArgumentError.new "Snapshot already exists '#{file_path}', make sure to implement the #{self.class.to_s} parse method." if File.exist? file_path

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
