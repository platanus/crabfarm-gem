require 'forwardable'
require 'crabfarm/utils/shell/frame'

module Crabfarm::Utils::Shell

  class ContainerFrame < Frame

    class Child
      extend Forwardable

      attr_reader :frame

      def_delegators :@frame, :prepare, :render, :grows?, :action_map

      def initialize(_frame, _options)
        @frame = _frame
        @options = _options
      end

      def min_lines
        @options.fetch(:min_lines, @frame.min_lines)
      end

      def req_lines
        [@frame.req_lines, min_lines].max
      end

      def min_columns
        @options.fetch(:min_columns, @frame.min_columns)
      end

      def req_columns
        [@frame.req_columns, min_columns].max
      end

      def weight
        @options.fetch(:weight, 1.0)
      end
    end

    def initialize
      super
      @childs = []
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
      return false if @childs.length == 0

      focus_idx = if @focused.nil?
        @focused = @childs.first.frame
        0
      else
        @childs.index { |c| c.frame == @focused }
      end

      # binding.pry

      while not @focused.focus_next
        focus_idx += 1
        @focused.reset_focus

        if focus_idx >= @childs.length
          @focused = nil
          return false
        else
          @focused = @childs[focus_idx].frame
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
      @childs << Child.new(_frame, _options)
    end

    def prepare
      @childs.each(&:prepare)
    end

  private

    attr_reader :childs

  end
end