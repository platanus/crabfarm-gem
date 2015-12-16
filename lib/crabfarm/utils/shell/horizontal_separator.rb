require 'crabfarm/utils/shell/frame'

module Crabfarm::Utils::Shell

  class HorizontalSeparator < Frame

    def min_columns(_columns)
      1
    end

    def max_columns(_columns)
      1
    end

    def render(_context)
      _context.lines.times { _context.write_line('|') }
    end
  end
end