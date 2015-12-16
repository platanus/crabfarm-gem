require 'forwardable'
require 'crabfarm/utils/shell/frame'

module Crabfarm::Utils::Shell

  class ContainerFrame < Frame

    class Child < Struct.new(:frame, :options); end

    def initialize
      super
      @children = []
      @focused = nil
    end

    def focused?
      not @focused.nil?
    end

    def reset_focus
      if @focused
        @focused.reset_focus
        @focused = nil
      end
    end

    def focus_next
      return false if @children.length == 0

      focus_idx = if @focused.nil?
        @focused = @children.first.frame
        0
      else
        @children.index { |c| c.frame == @focused }
      end

      while not @focused.focus_next
        focus_idx += 1
        @focused.reset_focus

        if focus_idx >= @children.length
          @focused = nil
          return false
        else
          @focused = @children[focus_idx].frame
        end
      end

      return true
    end

    def handle_key(_key, _app)
      return true if @focused && @focused.handle_key(_key, _app)
      super
    end

    def full_action_map
      super.merge(@focused.nil? ? {} : @focused.full_action_map)
    end

    def add_frame(_frame, _options={})
      _frame.reset_focus
      @children << Child.new(_frame, _options)
    end

  private

    attr_reader :children

  end
end