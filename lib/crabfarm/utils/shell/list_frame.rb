require 'crabfarm/utils/shell/titled_frame'

module Crabfarm::Utils::Shell
  class ListFrame < TitledFrame

    attr_accessor :render_header, :count_column

    def initialize
      super
      action(nil, "[") { move_cursor(-10) }
      action(nil, "]") { move_cursor(10) }
      action(nil, "\e[A") { move_cursor(-1) }
      action(nil, "\e[B") { move_cursor(1) }

      self.list = []
      self.render_header = true
      self.count_column = 6

      @columns = []
    end

    def column(_name, _options={}, &_block)
      _options = _name if _name.is_a? Hash
      _options[:label] = _name.to_s unless _options.key? :label
      _options[:render] = _block.nil? ? _name.to_proc : _block
      @columns << _options
      reset_column_stats
    end

    def list=(_new_list)
      @list = _new_list
      @scroll = 0
      @cursor = 0
    end

    def <<(_item)
      @list << _item
    end

    def current_item
      @list[@cursor]
    end

    def item_action(_action, _keys, &_block)
      action(_action, _keys) do |key, app|
        _block.call(current_item, key, app) if current_item
      end
    end

    def move_cursor(_offset)
      @cursor += _offset
      @cursor = @list.length - 1 if @cursor >= @list.length
      @cursor = 0 if @cursor < 0
    end

  private

    def min_content_columns(_columns)
      min_columns
    end

    def required_content_lines(_lines, _columns)
      if render_header
        @list.length + 1
      else
        @list.length
      end
    end

    def reset_column_stats
      @total_weight = nil
      @min_columns = nil
    end

    def total_weight
      @total_weight ||= @columns.inject(0) { |r,c| if c[:width] then r else r + c.fetch(:weight, 1.0) end }
    end

    def min_columns
      @min_columns ||= @columns.inject(0) { |r,c| if c[:width] then r + c[:width] else r end }
    end

    def render_content(_context)
      lines = _context.lines
      widths = load_widths _context

      if render_header
        header = render_column_headers widths, _context
        header = " " * count_column + header if count_column > 0
        _context.write_line header
        lines -= 1
      end

      if @cursor >= @scroll + lines
        @scroll = @cursor - lines + 1
      elsif @cursor < @scroll
        @scroll = @cursor
      end

      end_idx = [@list.count, @scroll + lines].min

      (@scroll...end_idx).each do |i|
        row = render_row widths, @list[i]
        row = crop_to_width("[#{i}]", count_column) + row if count_column > 0
        _context.write_line row, color: row_color(i)
      end
    end

    def load_widths(_context)
      space = _context.columns - (@columns.length - 1) - count_column # consider separators and numbering
      @columns.map do |column|
        width = column.fetch(:width, (column.fetch(:weight, 1.0) * (space - min_columns) / total_weight))
        width.round
      end
    end

    def render_column_headers(_widths, _context)
      _widths.each_with_index.map do |width, i|
        crop_to_width(@columns[i][:label].upcase, width)
      end.join(' ')
    end

    def render_row(_widths, _item)
      _widths.each_with_index.map do |width, i|
        data = @columns[i][:render].call _item
        crop_to_width(data.to_s, width)
      end.join(' ')
    end

    def row_color(_index)
      if @cursor == _index
        focused? ? :green : '#555555'
      else
        nil
      end
    end

    def crop_to_width(_string, _width)
      _string = _string[0.._width-1] if _string.length > _width
      _string += ' ' * (_width - _string.length) if _string.length < _width
      _string
    end

  end
end