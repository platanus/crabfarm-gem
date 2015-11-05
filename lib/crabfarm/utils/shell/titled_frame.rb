require 'crabfarm/utils/shell/frame'

module Crabfarm::Utils::Shell
  class TitledFrame < Frame

    attr_accessor :title

    def render(_context)
      unless title.nil?
        _context.write_line prepared_title(_context.columns), color: title_color
        _context = _context.child_context 1, 0, _context.lines-1, _context.columns
      end

      render_content _context
    end

    def min_lines(_lines)
      if title.nil?
        min_content_lines(_lines)
      else
        min_content_lines(_lines - 1) + 1
      end
    end

    def required_lines(_lines, _columns)
      if title.nil?
        required_content_lines(_lines, _columns)
      else
        required_content_lines(_lines - 1, _columns) + 1
      end
    end

    def min_columns(_columns)
      min_content_columns(_columns)
    end

    def required_columns(_lines, _columns)
      required_content_columns(_lines, _columns)
    end

  private

    def min_content_lines(_lines)
      0
    end

    def min_content_columns(_columns)
      0
    end

    def required_content_lines(_lines, _columns)
      0
    end

    def required_content_columns(_lines, _columns)
      0
    end

    def render_content(_context)
      # abstract
    end

    def title_color
      focused? ? :green : nil
    end

    def prepared_title(_columns)
      if title.length > 0
        title + ' ' + ('-' * (_columns - title.length - 1))
      else
        '-' * _columns
      end
    end
  end
end