module Crabfarm
  class LoaderService

    def self.load_state(_name)
      load_entity _name, 'state', BaseState
    end

    def self.load_parser(_name)
      load_entity _name, 'parser', BaseParser
    end

  private

    def self.load_entity(_name, _role, _type)

      if _name.is_a? String or _name.is_a? Symbol
        name = _name.to_s.gsub(/[^A-Z0-9:]+/i, '_').camelize
        mod = name.constantize rescue nil
      else
        mod = _name
      end

      raise EntityNotFoundError.new _role, name if mod.nil?
      raise EntityNotFoundError.new _role, name unless mod < _type
      mod
    end

  end
end
