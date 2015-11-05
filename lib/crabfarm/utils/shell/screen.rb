require 'crabfarm/utils/shell/screen_builder'

module Crabfarm::Utils::Shell
  class Screen

    ESCAPED_CHARS = "\r\n\e"

    attr_reader :lines, :columns, :data_buffer, :style_buffer

    def initialize(_lines=1, _columns=1)
      resize _lines, _columns
    end

    def resize(_lines, _columns)
      @lines = _lines
      @columns = _columns
      @length = @lines * @columns
      reset_buffers
      force_full_redraw
    end

    def force_full_redraw
      @last_data = nil
      @last_style = nil
    end

    def paint(_line, _column, _string, _width, _style)
      return if _column >= @columns or _line >= @lines

      _width = @columns - _column if _column + _width > @columns
      offset = _line * @columns + _column

      _width.times do |i|
        @data[offset + i] = sanitize(_string[i] || ' ')
        @style[offset + i] = _style
      end
    end

    def flush(_redraw=false)
      data = if @last_data.nil? or _redraw
        simple_flush
      else
        diff_flush
      end

      rotate
      data
    end

  private

    def sanitize(_char)
      return ' ' if _char == "\t" # TODO: tab size!
      if ESCAPED_CHARS.include? _char then '?' else _char end
    end

    def reset_buffers
      @data = Array.new @length, ' '
      @style = Array.new @length
    end

    def rotate
      @last_data = @data
      @last_style = @style
      reset_buffers
    end

    def diff_flush
      builder = ScreenBuilder.new
      @data.each_with_index do |char, idx|
        builder.return if idx > 0 && idx % @columns == 0

        style = @style[idx]
        if @last_data[idx] == char and @last_style[idx] == style
          builder.jump
        else
          builder.char char, style
        end
      end
      builder.dump
    end

    def simple_flush
      builder = ScreenBuilder.new
      @data.each_with_index do |char, idx|
        builder.return if idx > 0 && idx % @columns == 0
        builder.char char, @style[idx]
      end
      builder.dump
    end

    def detect_size
      @lines = utils.lines
      @columns = utils.columns
    end

    def detect_size
      @lines = utils.lines
      @columns = utils.columns
    end
  end
end