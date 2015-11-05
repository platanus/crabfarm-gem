require 'crabfarm/modes/analizer/trace_service'

module Crabfarm::Modes::Analizer
  class TraceFilter

    def initialize(_requests, _start, _stop_word)
      @selected = TraceService.new(_requests).trace(_start, _stop_word)
      @start = _start
      @stop_word = _stop_word
    end

    def inspect
      "Trace #{@start.uri.path} > #{@stop_word}"
    end

    def accept?(_req)
      @selected.include? _req
    end
  end
end