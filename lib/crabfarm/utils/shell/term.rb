require 'io/console'

module Crabfarm::Utils::Shell
  module Term
    extend self

    def lines
      %x[tput lines].to_i
    end

    def columns
      %x[tput cols].to_i - 1
    end

    def write(_str)
      # $stdout.raw!
      $stdout.write _str
    end

    def flush
      $stdout.ioflush
    end

    def move(_dir)
      write "\e[#{_dir[:up]}A" if _dir.has_key? :up
      write "\e[#{_dir[:down]}B" if _dir.has_key? :down
      write "\e[#{_dir[:right]}C" if _dir.has_key? :right
      write "\e[#{_dir[:left]}D" if _dir.has_key? :left
    end

    def goto(_where)
      if _where == :origin
        write "\e[H"
      elsif _where.has_key? :line
        write "\e[#{_where[:line]};#{_where.fetch(:column, 0)}H"
      else
        write "\e[#{_where[:column]}G"
      end
    end

    def erase_display
      write "\e[2J"
    end

    def erase_below
      write "\e[0J"
    end

    def erase_above
      write "\e[1J"
    end

    def erase_line
      write "\e[2K"
    end

    def erase_right
      write "\e[0K"
    end

    def erase_left
      write "\e[1K"
    end

    def switch_to_alternate_buffer
      write "\e[?1049h" # xterm
    end

    def switch_to_normal_buffer
      write "\e[?1049l" # xterm
    end

    def in_app_mode
      echo_was = $stdin.echo?
      sync_was = $stdout.sync
      $stdout.sync = true
      $stdout.echo = false
      switch_to_alternate_buffer
      yield
    ensure
      switch_to_normal_buffer
      $stdout.sync = sync_was
      $stdin.echo = echo_was
    end

    def show_cursor
      write "\e[?25h"
    end

    def hide_cursor
      write "\e[?25l"
    end

    def read_char(_timeout=nil)
      echo_status = $stdin.echo?
      $stdin.echo = false
      $stdin.raw!

      unless _timeout.nil?
        # this is not working properly, some characters are lost!
        return nil if IO.select([$stdin], nil, nil, _timeout).nil?
      end

      input = $stdin.readchar

      if input == "\e" then
        input << $stdin.read_nonblock(3) rescue nil
        input << $stdin.read_nonblock(2) rescue nil
      end

      return input
    ensure
      $stdin.cooked!
      $stdin.echo = echo_status
    end
  end
end