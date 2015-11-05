require 'crabfarm/utils/shell/frame'

module Crabfarm::Utils::Shell

  class BannerFrame < Frame

    attr_accessor :text

    def initialize(_text="")
      super()
      @text = _text
    end

    def focus_next
      false
    end

    def min_lines(_lines)
      2
    end

    def max_lines(_lines)
      2
    end

    def render(_context)
      _context.write_line @text
      _context.write_line '*' * _context.columns
    end
  end
end