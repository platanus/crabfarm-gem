require 'crabfarm/utils/shell/render_context'
require 'crabfarm/utils/shell/actionable'
require 'crabfarm/utils/shell/screen'
require 'crabfarm/utils/shell/term'
require 'crabfarm/utils/shell/utils'
require 'crabfarm/utils/shell/prompt'

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
      load_default_actions

      term.in_app_mode do
        expand_screen
        trap_resize_signal

        loop do
          begin
            render_default
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
    ensure
      term.show_cursor
    end

    def prompt(_help="", _placeholder="%")
      _placeholder = "#{_placeholder}> "

      prompt = Prompt.new
      loop do
        render_prompt _help, _placeholder
        term.show_cursor

        loop do
          term.goto column: _placeholder.length + 1
          term.erase_right

          prompt.render term

          char = term.read_char timeout # TODO: writing a lot will prevent refresh
          break if char.nil?
          return prompt.buffer if char == "\r"
          return nil if char == "\e"
          prompt.feed char
        end
      end
    end

    def full_action_map
      action_map.merge(main_frame.nil? ? {} : main_frame.full_action_map)
    end

  private

    def timeout
      0.5
    end

    def screen
      @screen ||= Screen.new
    end

    def expand_screen
      screen.resize term.lines, term.columns
    end

    def flush_screen
      term.hide_cursor
      term.goto :origin
      term.write screen.flush
    end

    def trap_resize_signal
      main_th = Thread.current
      Signal.trap("SIGWINCH") do
        # do something with to reload screen dimensions
        # maybe: main_th.raise StandardError.new 'resizing!'
      end
    end

    def load_default_actions
      action('quit', ["q", "\u0003"]) { exit(1) }
      action('switch focus', "\t") { switch_focus }
    end

    def render_default
      ctx = prepare_context
      render_content ctx, 1
      render_footer ctx
      flush_screen
      # TODO: position cursor if main_frame.cursor
    end

    def render_prompt(_help, _prompt)
      ctx = prepare_context
      render_content ctx, 2
      ctx.write_line _help, color: :yellow
      ctx.write_line _prompt
      flush_screen
    end

    def prepare_context
      RenderContext.new screen, nil, 0, 0, screen.lines, screen.columns
    end

    def render_content(_ctx, _footer_size)
      if main_frame
        main_frame.render _ctx.child_context(0, 0, screen.lines - _footer_size, screen.columns)
      end

      _ctx.goto_line screen.lines - _footer_size
    end

    def render_footer(_ctx)
      if @flash
        _ctx.write_line @flash
        @flash = nil
      else
        _ctx.write_line help_string, color: :yellow
      end
    end

    def wait_for_user
      char = term.read_char timeout
      return if char.nil?
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

    def help_string
      actions = {}
      full_action_map.each { |k, a| actions[a] = k unless a.help.nil? || actions[a] }
      "Press " + actions.map { |a, k| "`#{utils.humanize_key k}` to #{a.help}" }.join(', ')
    end

    def term
      Term
    end

    def utils
      Utils
    end
  end
end