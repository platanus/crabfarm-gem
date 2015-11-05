require 'crabfarm/utils/shell/utils'

module Crabfarm::Utils::Shell
  class RenderContext

    attr_accessor :parent, :lines, :columns

    def initialize(_screen, _parent, _line_offset, _column_offset, _lines, _columns)
      @screen = _screen
      @parent = _parent
      @line_offset = _line_offset
      @column_offset = _column_offset
      @lines = _lines
      @columns = _columns

      @line_cursor = 0
    end

    def child_context(_line_offset, _column_offset, _lines, _columns)
      _line_offset = @lines if _line_offset > @lines
      _column_offset = @columns if _column_offset > @columns
      _lines = @lines - _line_offset if _lines > @lines - _line_offset
      _columns = @columns - _column_offset if _columns > @columns - _column_offset

      self.class.new(
        @screen,
        self,
        @line_offset + _line_offset,
        @column_offset + _column_offset,
        _lines,
        _columns
      )
    end

    def write_line(_line, _style=nil)
      if @line_cursor >= 0 and @line_cursor < @lines
        @screen.paint(@line_offset + @line_cursor, @column_offset, _line, @columns, _style)
      end

      @line_cursor += 1
    end

    def skip_line
      @line_cursor += 1
    end

    def goto_line(_offset)
      @line_cursor = _offset
    end

  private

    def utils
      Utils
    end

  end
end