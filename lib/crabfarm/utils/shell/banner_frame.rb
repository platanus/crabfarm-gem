require 'crabfarm/utils/shell/frame'

module Crabfarm::Utils::Shell

  class BannerFrame < Frame

    attr_accessor :text

    def initialize(_text="")
      super()
      @text = _text
      @count = 0
    end

    def focus_next
      false
    end

    def render(_context)
      @count += 1
      _context.write_line @text + @count.to_s
      _context.write_line '*' * _context.columns
    end
  end
end