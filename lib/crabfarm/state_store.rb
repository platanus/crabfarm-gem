module Crabfarm
  class StateStore < Hash

    def initialize
      super
    end

    def set(_key, _value=true)
      self[_key] = _value
    end

    def is?(_key)
      !!fetch(_key, false)
    end

    def reset
      clear
    end

  end

end
