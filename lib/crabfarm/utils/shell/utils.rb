require 'io/console'

module Crabfarm::Utils::Shell
  module Utils
    extend self

    def humanize_key(_char)
      case _char
      when "\t" then 'TAB'
      when "\e" then 'ESC'
      when "\e[A" then 'UP'
      when "\e[B" then 'DOWN'
      else _char
      end
    end
  end
end