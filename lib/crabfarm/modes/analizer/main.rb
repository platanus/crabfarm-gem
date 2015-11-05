require 'pry'
require 'json'
require 'zlib'
require 'base64'
require 'nokogiri'
require 'crabfarm/utils/shell/app'
require 'crabfarm/utils/shell/layout_frame'
require 'crabfarm/utils/shell/list_frame'
require 'crabfarm/utils/shell/banner_frame'
require 'crabfarm/utils/shell/viewer_frame'

require 'crabfarm/modes/analizer/request'
require 'crabfarm/modes/analizer/filter'
require 'crabfarm/modes/analizer/trace_filter'

module Crabfarm
  module Modes
    module Analizer
      class Main

        def self.start(_memento)
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
          @requests = []
          @filters = []
          build_ui
          reset_ui
        end

        def analize(_memento)
          @memento = Crabfarm::Utils::Resolve.memento_path _memento

          json = JSON.parse inflate @memento
          json = { 'version' => '0.1', 'stack' => json } if json.is_a? Array

          @version = json['version']
          @requests = parse_memento_stack json['stack']
          @filters = []

          reset_ui
        end

        def start
          @ui_app.start
        end

      private

        def build_ui
          @ui_details = Crabfarm::Utils::Shell::LayoutFrame.new
          @ui_banner = Crabfarm::Utils::Shell::BannerFrame.new 'Analizer v0.1'

          @ui_all = Crabfarm::Utils::Shell::ListFrame.new
          @ui_all.item_action('select item', "a") { |i| @ui_selected << i }
          @ui_all.item_action('trace', "t") { |i| add_trace_filter_for i }
          prepare_request_list_view @ui_all

          @ui_selected = Crabfarm::Utils::Shell::ListFrame.new
          @ui_selected.title = "-- Selected Requests"
          @ui_selected.render_header = false
          prepare_request_list_view @ui_selected

          @ui_dashboard = Crabfarm::Utils::Shell::LayoutFrame.new
          @ui_dashboard.add_frame @ui_banner, min_lines: 2
          @ui_dashboard.add_frame @ui_all
          @ui_dashboard.add_frame @ui_selected, min_lines: 10, weight: 0.5

          @ui_dashboard.action('search', "s") { add_search_filter }
          @ui_dashboard.action('undo filter', "u") { remove_last_filter }

          @ui_sent_header_viewer = Crabfarm::Utils::Shell::ViewerFrame.new
          @ui_sent_header_viewer.title = "-- Request"
          @ui_header_viewer = Crabfarm::Utils::Shell::ViewerFrame.new
          @ui_header_viewer.title = "-- Response Headers"
          @ui_request_viewer = Crabfarm::Utils::Shell::ViewerFrame.new
          @ui_request_viewer.title = "-- Request Content"
          @ui_response_viewer = Crabfarm::Utils::Shell::ViewerFrame.new
          @ui_response_viewer.title = "-- Response Content"

          @ui_details = Crabfarm::Utils::Shell::LayoutFrame.new
          @ui_details.add_frame @ui_banner, min_lines: 2
          @ui_details.add_frame @ui_sent_header_viewer
          @ui_details.add_frame @ui_header_viewer
          @ui_details.add_frame @ui_response_viewer
          @ui_details.add_frame @ui_request_viewer
          @ui_details.action('back to list', "\e") { load_dashboard }

          @ui_app = Crabfarm::Utils::Shell::App.new
        end

        def prepare_request_list_view(_list_frame)
          _list_frame.column(:method, width: 7)
          _list_frame.column(:url)
          _list_frame.column(label: 'Content type', width: 30) { |i| i.headers['content-type'] }
          _list_frame.column(label: 'Sets cookies', width: 20) { |i| !i.headers['set-cookie'].nil? }

          _list_frame.item_action(nil, "\r") { |i| load_details i }
          _list_frame.item_action(nil, "h") { |i| add_filter :host, i.host }
          _list_frame.item_action(nil, "c") { |i| add_filter :content_type, i.content_type }
        end

        def reset_ui
          @ui_app.main_frame = @ui_dashboard
          @ui_selected.list = []
          @ui_all.title = "-- All Requests [#{@requests.count}]"
          @ui_all.list = @requests
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
          filtered = @requests.select do |req|
            @filters.all? { |f| f.accept? req }
          end

          @ui_all.title = "-- #{filtered.count} of #{@requests.count} Requests [Filters: #{@filters.map(&:inspect).join(', ')}]"
          @ui_all.list = filtered
        end

        def add_search_filter
          q = @ui_app.prompt('What are you looking for?', 'search')
          add_filter :search, q if q and q != ''
        end

        def add_trace_filter_for(_request)
          stop = @ui_app.prompt('Enter stop word', 'trace')
          if stop
            trace = TraceService.new(@requests).trace(_request, stop)
            @ui_selected.list = @requests.select { |r| trace.include? r }
          end
          # @filters << TraceFilter.new(@requests, _request, stop) if stop != ''
          # apply_filters
        end

        def load_dashboard
          @ui_app.main_frame = @ui_dashboard
        end

        def load_details(_req)
          @ui_sent_header_viewer.text =
            "#{_req.method.upcase} #{_req.url}\n" +
            _req.sent_headers.map { |k,v| " + #{k}: #{v}" }.join("\n")

          @ui_header_viewer.text = _req.headers.map { |k,v| " + #{k}: #{v}" }.join("\n")
          @ui_response_viewer.text = format_response _req.response_data, _req.headers['content-type']
          @ui_request_viewer.text = _req.request_data
          @ui_app.main_frame = @ui_details
        end

        def parse_memento_stack(_stack)
          _stack.map { |r| Request.from_raw_resource r }
        end

        def inflate(_file)
          Zlib::GzipReader.open(_file) { |gz| gz.read }
        end

        def format_response(_response, _content_type)
          if /text\/html/.match _content_type
            Nokogiri::HTML(_response).to_xhtml(indent: 3)
          else
            _response
          end
        end
      end
    end
  end
end
