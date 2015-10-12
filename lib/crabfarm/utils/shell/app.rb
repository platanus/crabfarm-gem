require 'readline'
require 'rainbow'
require 'crabfarm/utils/shell/render_context'
require 'crabfarm/utils/shell/actionable'

module Crabfarm::Utils::Shell

  class App
    include Actionable

    attr_reader :main_frame, :float_frame

    attr_accessor :flash

    def main_frame=(_frame)
      @main_frame = _frame
      @main_frame.focus_next unless @main_frame.focused?
    end

    def start
      prepare
      utils.clear

      main_th = Thread.current
      Signal.trap("SIGWINCH") do
        main_th.raise StandardError.new 'resizing!'
      end

      loop do
        begin
          render
          wait_for_user
        # rescue SyntaxError => se
        #   self.flash = Rainbow(se.message).red
        rescue SystemExit, Interrupt
          break
        # rescue => exc
        #   self.flash = Rainbow(exc.message).red
        end
      end

    end

    def prompt(_help="", _placeholder="%")
      ctx = render_content
      ctx.write_line _help, :yellow
      ctx.skip_line
      Readline.readline("#{_placeholder}> ", true)
    end

    def full_action_map
      action_map.merge(main_frame.nil? ? {} : main_frame.full_action_map)
    end

  private

    def prepare
      utils.clear
      detect_size
      load_default_actions
    end

    def load_default_actions
      action(nil, ["\u0003"]) { exit(1) }
      action('switch focus', "\t") { switch_focus }
    end

    def detect_size
      @lines = utils.lines
      @columns = utils.columns
    end

    def render
      ctx = render_content
      render_footer ctx
      utils.flush
    end

    def render_content
      ctx = RenderContext.new nil, 1, 1, @lines, @columns

      utils.origin
      utils.clear_lines @lines - footer_size

      if main_frame
        main_frame.prepare
        main_frame.render ctx.child_context(0, 0, @lines - footer_size, @columns)
      end

      ctx.goto_line @lines - footer_size
      ctx
    end

    def wait_for_user
      char = utils.read_char
      unless main_frame.handle_key char, self
        handle_key char, self
      end
    end

    def switch_focus
      if main_frame
        unless main_frame.focus_next
          main_frame.reset_focus
          main_frame.focus_next
        end
      end
    end

    def footer_size
      2
    end

    def render_footer(_ctx)
      if @flash
        _ctx.write_line @flash
        @flash = nil
      else
        _ctx.write_line help_string, :yellow
      end
      _ctx.write_line "%\e[D"
    end

    def help_string
      actions = {}
      full_action_map.each { |k, a| actions[a] = k unless a.help.nil? || actions[a] }
      "shortcuts: " + actions.map { |a, k| "`#{humanize_key k}` to #{a.help}" }.join(', ')
    end

    def humanize_key(_key)
      case _key
      when "\t" then 'TAB'
      when "\e" then 'ESC'
      when "\e[A" then 'UP'
      when "\e[B" then 'DOWN'
      else _key
      end
    end

    def utils
      Utils
    end
  end
end