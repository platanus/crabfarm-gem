require 'crabfarm/utils/shell/frame'

module Crabfarm::Utils::Shell
  class TitledFrame < Frame

    attr_accessor :title

    def render(_context)
      unless title.nil?
        _context.write_line prepared_title(_context.columns), title_color
        _context = _context.child_context 1, 0, _context.lines-1, _context.columns
      end

      render_content _context
    end

    def req_lines
      if title.nil?
        req_content_lines
      else
        req_content_lines + 1
      end
    end

  private

    def req_content_lines
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