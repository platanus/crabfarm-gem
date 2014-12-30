require 'active_support'

module Crabfarm
  class ModuleHelper

    attr_reader :dsl

    def initialize(_module)
      @module = _module
    end

    def settings
      @module::CF_CONFIG
    end

    def load_state(_name)
      load_entity _name, 'state', BaseState
    end

    def load_parser(_name)
      load_entity _name, 'parser', BaseParser
    end

  private

    def load_entity(_name, _role, _type)
      name = _name.to_s.gsub(/[^A-Z0-9:]+/i, '_').camelize
      mod = @module.const_get(name) rescue nil
      raise EntityNotFoundError.new _role, name if mod.nil?
      raise EntityNotFoundError.new _role, name unless mod < _type
      mod
    end

  end
end
