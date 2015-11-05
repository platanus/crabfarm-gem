require 'io/console'

module Crabfarm::Utils::Shell
  class Prompt

    attr_reader :buffer, :cursor

    def initialize
      # TODO: add max width and related behavior
      @buffer = ''
      @cursor = 0
    end

    def feed(_char)
      case _char
      when "\e[D"
        @cursor -= 1
        @cursor = 0 if @cursor < 0
      when "\e[C"
        @cursor += 1
        @cursor = @buffer.length if @cursor > @buffer.length
      when "\b", "\u007F"
        if @cursor > 0
          @buffer = (@buffer[0..@cursor-1][0..-2]) + (@buffer[@cursor..-1] || '')
          @cursor -= 1
        end
      else
        return if _char[0] == "\e"
        if @cursor > 0
          @buffer = @buffer[0..@cursor-1] + _char + (@buffer[@cursor..-1] || '')
        else
          @buffer = _char + @buffer
        end
        @cursor += 1
      end
    end

    def render(_term)
      _term.write buffer
      _term.move left: (buffer.length - cursor) if buffer.length > cursor
    end
  end
end