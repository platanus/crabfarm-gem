require 'active_support'

module Crabfarm
  class StateStore

    def initialize(_module)
      reset
    end

    def fetch(key, &block)
      @data.fetch(key.to_sym, &block)
    end

    def set(key, value)
      @data[key.to_sym] = value
    end

    def reset
      @data = Hash.new
    end

  end

end
