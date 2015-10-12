require 'crabfarm/utils/shell/utils'

module Crabfarm::Utils::Shell
  class RenderContext

    attr_accessor :parent, :lines, :columns

    def initialize(_parent, _line_offset, _column_offset, _lines, _columns)
      @parent = _parent
      @line_offset = _line_offset
      @column_offset = _column_offset
      @lines = _lines
      @columns = _columns

      @line_cursor = 0
      @max_width = @columns - @column_offset
    end

    def child_context(_line_offset, _column_offset, _lines, _columns)
      self.class.new(
        self,
        @line_offset + _line_offset,
        @column_offset + _column_offset,
        [_lines, @lines - _line_offset].min,
        [_columns, @columns - _column_offset].min
      )
    end

    def write_line(_line, _color=nil)
      return nil if @line_cursor >= @lines

      _line = sanitize _line

      # crop line if needed
      _line = _line[0..@max_width] if _line.length > @max_width
      _line = Rainbow(_line).color(_color) if _color

      utils.origin @line_offset + @line_cursor, @column_offset
      utils.clear_line # TODO: clear max
      utils.write _line

      @line_cursor += 1
    end

    def skip_line
      write_line("")
    end

    def goto_line(_offset)
      @line_cursor = _offset
    end

    def sanitize(_string)
      _string.gsub "\n", " "
    end

  private

    def utils
      Utils
    end

  end
end