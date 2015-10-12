require 'crabfarm/utils/shell/actionable'

module Crabfarm::Utils::Shell
  class Frame
    include Actionable

    def initialize
      @focused = false
    end

    def focused?
      @focused || false
    end

    def reset_focus
      @focused = false
    end

    def focus_next
      if @focused
        return false
      else
        @focused = true
        return true
      end
    end

    def min_lines
      1
    end

    def min_columns
      1
    end

    def req_lines
      0
    end

    def req_columns
      0
    end

    def grows?
      true
    end

    def prepare
      # abstract
    end

    def render(_context)
      # abstract
    end

    def full_action_map
      action_map
    end
  end
end