require 'readline'
require 'json'
require 'zlib'
require 'rainbow'
require 'crabfarm/utils/console'
require 'io/console'
require 'base64'

URI::DEFAULT_PARSER = URI::Parser.new(:UNRESERVED => URI::REGEXP::PATTERN::UNRESERVED + '|')

module Crabfarm
  module Modes
    class Analizer

      class Request < Struct.new(:method, :url, :headers, :request_data, :response_data)

        TEXT_TYPES = ['application/javascript','application/x-javascript']

        def uri
          @uri ||= URI.parse url
        end

        def host
          uri.host
        end

        def content_type
          @ct ||= (headers['content-type'] || 'text/plain').gsub(/;.*/,'')
        end

        def is_text?
          return true if content_type.start_with? 'text/'
          TEXT_TYPES.include? content_type
        end

      end

      class Filter

        def initialize(_type, _value)
          @type = _type
          @value = _value
        end

        def inspect
          "#{@type} = #{@value}"
        end

        def accept?(_req)
          case @type
          when :content_type
            _req.content_type == @value
          when :host
            _req.host == @value
          when :search
            return true unless _req.url.index(@value).nil?
            return true unless _req.request_data.index(@value).nil?
            return true if _req.is_text? and !_req.response_data.index(@value).nil?
            return false
          else true end
        end

      end

      def self.start(_memento)

        $stdout.sync = true

        unless _memento.is_a? String
          Crabfarm::Utils::Console.error "Must provide a recording target"
          return
        end

        memento_path = Crabfarm::Utils::Resolve.memento_path _memento

        if not File.exist? memento_path
          Crabfarm::Utils::Console.error "Memento file does not exist: #{memento_path}"
          return
        end

        analizer = self.new
        analizer.analize _memento
        analizer.start
      end

      def initialize
        @memento = nil
        @filtered = @requests = []
        reset_ui
      end

      def analize(_memento)
        @memento = Crabfarm::Utils::Resolve.memento_path _memento

        json = JSON.parse inflate @memento
        json = { 'version' => '0.1', 'stack' => json } if json.is_a? Array

        @version = json['version']
        @filtered = @requests = parse_memento_stack json['stack']
        reset_ui
      end

      def reset_ui
        @selected = []
        @filters = []
        @scroll = 0
        @cursor = 0
        @focus = :requests
        @mode = :explore
        @current = nil
      end

      def start
        console.clear
        console.detect
        #set_help_flash

        main_th = Thread.current
        Signal.trap("SIGWINCH") do
          main_th.raise StandardError.new 'resizing!'
        end

        loop do
          begin
            console.detect
            render
            #set_help_flash
            wait_for_user
          rescue SyntaxError => se
            @flash = se.message.color(:red)
            # Crabfarm::Utils::Console.exception se
          rescue SystemExit, Interrupt
            break
          rescue => exc
            @flash = exc.message.color(:red)
            # Crabfarm::Utils::Console.exception exc
          end
        end
      end

    private

      attr_reader :selected, :requests, :scroll, :focus, :mode

      def wait_for_user
        case @mode
        when :explore
          capture_actions
        when :search
          query = Readline.readline("search> ", true)
          add_filter :search, query if query.length > 0
          @mode = :explore
        when :run
          # TODO.
        end
      end

      def render
        if @current
          render_request @current
        else
          render_dashboard
        end
      end

      def render_layout
        console.origin
        console.jump_line
        console.write_line "Crabfarm v#{Crabfarm::VERSION} Analizer by Platanus".color(:blue)
        console.jump_line
      end

      def render_dashboard
        render_layout

        render_separator " + Selected Requests"

        selected_space = [selected.count, 5].max
        render_requests selected, selected_space, 0, (focus == :selected ? @cursor : nil)

        console.jump_line
        render_separator " + #{render_list_header}"

        render_requests @filtered, console.lines - selected_space - 11, scroll, (focus == :requests ? @cursor : nil)
        render_separator

        if @flash
          console.write_line @flash
          @flash = nil
        else
          console.write_line ""
        end

        console.clear_line
      end

      def render_request(_req)
        render_layout
        render_separator " + Request Details"

        console.write_line "Method: #{_req.method}"
        console.write_line "URL: #{_req.url}"
        render_separator " Resquest Data"
        console.write_line _req.request_data
        render_separator " Response Headers"
        console.write_line _req.headers
        render_separator " Response Data"
        console.write_line _req.response_data
      end

      def render_list_header
        if @filters.length > 0
          "#{@filtered.count} of #{@requests.count} Requests [Filters: #{@filters.map(&:inspect).join(', ')}]"
        else
          "All Requests [#{@requests.count}]"
        end
      end

      def render_separator(_string="")
        separator = if _string.length > 0
          _string + ' ' + ('-' * (console.columns - _string.length - 1))
        else
          '-' * console.columns
        end
        console.write_line separator
      end

      def render_requests(_list, _max, _offset, _cursor)
        if !_cursor.nil? && _cursor > _offset + _max
          _offset = _cursor - _max
        end

        max_idx = _offset + _max
        end_idx = [_list.count-1, max_idx].min

        (_offset..end_idx).each do |i|
          row = [
            render_column("[#{i}]", 5),
            render_column(_list[i].method, 4),
            render_column(_list[i].url, console.columns - (31 + 21 + 5 + 6 + 1)),
            render_column(_list[i].headers['content-type'].to_s, 30),
            render_column((!_list[i].headers['set-cookie'].nil?).to_s, 20)
          ]

          row = row.join
          row = row.color(:green) if _cursor == i

          console.write_line row
        end

        # padding
        (max_idx - end_idx).times { console.jump_line } if max_idx > end_idx
      end

      def render_column(_data, _width)
        _data = _data[0.._width-1] if _data.length > _width
        _data += ' ' * (_width - _data.length) if _data.length < _width
        _data + ' '
      end

      def capture_actions
        char = console.read_char
        case char
        when "\t"
          switch_focus
        when "\r"
          @current = current_request
        when "\e"
          if @current
            @current = nil
          else
            remove_last_filter
          end
        when "["
          move_cursor(-10)
        when "]"
          move_cursor(10)
        when "\e[A"
          move_cursor(-1)
        when "\e[B"
          move_cursor(1)
        when "\u0003", "q"
          exit(1)
        when "h" # filter by same host
          add_filter :host, current_request.host
        when "c" # filter by same content type
          add_filter :content_type, current_request.content_type
        when "u"
          remove_last_filter
        when "v"
          toggle_view
        when "s"
          @mode = :search
        else
          @flash = char.inspect
        end
      end

      def current_request
        list = @focus == :requests ? @filtered : @selected
        list[@cursor]
      end

      def switch_focus
        @focus = case @focus
        when :requests
          :selected
        else
          :requests
        end
      end

      def move_cursor(_amount)
        list = @focus == :requests ? @filtered : @selected

        @cursor = @cursor + _amount
        if @cursor < 0
          @cursor = 0
        elsif @cursor > list.length-1
          @cursor = list.length - 1
        end
      end

      def add_filter(_type, _value)
        @filters << Filter.new(_type, _value)
        apply_filters
      end

      def remove_last_filter
        @filters.pop
        apply_filters
      end

      def apply_filters
        @filtered = @requests.select do |req|
          @filters.all? { |f| f.accept? req }
        end
        @cursor = 0
      end

      def parse_memento_stack(_stack)
        _stack.map { |r| Request.new r['method'], r['url'], r['headers'], r['data'], Base64.decode64(r['content']) }
      end

      def inflate(_file)
        Zlib::GzipReader.open(_file) { |gz|
          return gz.read
        }
      end

      module Utils
        extend self

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

        def detect
          @lines = %x[tput lines].to_i
          @columns = %x[tput cols].to_i - 1
        end

        def clear
          system 'clear'
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

        def write_line(_string)
          $stdout.write _string
          jump_line
        end

        def lines
          @lines
        end

        def columns
          @columns
        end
      end

      def console
        Utils
      end

    end
  end
end
