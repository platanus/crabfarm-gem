require 'io/console'

module Crabfarm::Utils::Shell
  module Utils
    extend self

    def lines
      %x[tput lines].to_i
    end

    def columns
      %x[tput cols].to_i - 1
    end

    def clear
      system 'clear'
      $stdout.sync = false
    end

    def flush
      $stdout.flush
    end

    def origin(_row=0, _col=0)
      $stdout.write "\e[#{_row};#{_col}H"
    end

    def clear_line
      $stdout.write "\e[0K"
    end

    def jump_line
      clear_line
      $stdout.write "\n"
    end

    def clear_lines(_count)
      $stdout.write "\e[0K\n" * _count
    end

    def write(_string)
      $stdout.write _string
    end

    def read_char
      $stdin.echo = false
      $stdin.raw!

      input = $stdin.getc.chr
      if input == "\e" then
        input << $stdin.read_nonblock(3) rescue nil
        input << $stdin.read_nonblock(2) rescue nil
      end
    ensure
      $stdin.echo = true
      $stdin.cooked!

      return input
    end
  end
end