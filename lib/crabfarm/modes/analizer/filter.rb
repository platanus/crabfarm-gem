module Crabfarm::Modes::Analizer
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
        return true unless _req.headers.to_json.index(@value).nil?
        return true if _req.is_text? and !_req.response_data.index(@value).nil?
        return false
      else true end
    end
  end
end
