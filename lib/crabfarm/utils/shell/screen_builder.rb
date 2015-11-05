module Crabfarm::Utils::Shell
  class ScreenBuilder

    attr_reader :buffer

    def initialize
      @buffer = []
      @jumps = 0
      @crs = 0
      @style = nil
    end

    def char(_char, _style)
      prepare _style
      buffer << _char
    end

    def jump
      @jumps +=1
    end

    def return
      @jumps = 0
      @crs += 1
    end

    def dump
      prepare nil
      @buffer.join
    end

  private

    def prepare(_style)
      apply_crs if @crs > 0
      apply_jumps if @jumps > 0

      if @style != _style
        buffer << encode_style(_style)
        @style = _style
      end
    end

    def apply_jumps
      @buffer << "\e[#{@jumps}C"
      @jumps = 0
    end

    def apply_crs
      if @crs > 1
        @buffer << "\e[#{@crs}B"
        @buffer << "\e[G"
      else
        @buffer << "\n"
      end
      @crs = 0
    end

    def encode_style(_style)
      return "\e[0m" if _style.nil?
      case _style[:color]
      when :red then "\e[31m"
      when :green then "\e[32m"
      when :yellow then "\e[33m"
      else "\e[0m" end
    end

  end
end