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

    def min_lines(_lines)
      1
    end

    def min_columns(_lines)
      1
    end

    def max_lines(_lines)
      nil
    end

    def max_columns(_lines)
      nil
    end

    def required_lines(_lines, _columns)
      0
    end

    def required_columns(_lines, _columns)
      0
    end

    def render(_context)
      # abstract
    end

    def full_action_map
      action_map
    end
  end
end