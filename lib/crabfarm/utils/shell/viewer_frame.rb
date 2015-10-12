require 'crabfarm/utils/shell/titled_frame'

module Crabfarm::Utils::Shell

  class ViewerFrame < TitledFrame

    attr_accessor :wrapping

    def initialize(_text="")
      super()
      self.text = _text
      self.wrapping = :word

      action('pg up', "[") { scroll(-10) }
      action('pg down', "]") { scroll(10) }
      action('up', "\e[A") { scroll(-1) }
      action('down', "\e[B") { scroll(1) }

      action('search', "s") { |k,app| new_search(app) }
      action('next', "\r") { |k,app| search_next(app) }
    end

    def text=(_text)
      @offset = 0
      @lines = _text.split("\n")
    end

    def scroll(_offset)
      @offset += _offset
      @offset = 0 if @offset < 0
    end

    # TODO: line wrapping

    def min_lines
      1
    end

    def req_content_lines
      if wrapping == :none
        @lines.count
      else
        Float::INFINITY
      end
    end

    def new_search(_app)
      @term = _app.prompt('What are you looking for?', 'search')
      @term_location = -1
      search_next(_app)
    end

    def search_next(_app)
      return if @term.nil?
      rel_location = @lines.drop(@term_location + 1).index { |l| l.include? @term }
      if rel_location.nil?
        @term_location = -1
        @offset = 0
        # end of file reached
      else
        @term_location += rel_location + 1
        @offset = @term_location
      end
    end

    def render_content(_context)
      visible = @lines[@offset..@offset+_context.lines]

      case @wrapping
      when :word
        visible.each do |l|
          while l and l.length > 0
            _context.write_line l[0.._context.columns]
            l = l[_context.columns..-1]
          end
        end
      else
        visible.each { |l| _context.write_line l }
      end
    end
  end
end