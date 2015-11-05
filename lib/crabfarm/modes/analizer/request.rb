require 'crabfarm/modes/analizer/utils'

module Crabfarm::Modes::Analizer
  class Request < Struct.new(:method, :url, :sent_headers, :headers, :request_data, :response_data)

    TEXT_TYPES = ['application/javascript','application/x-javascript']

    def self.from_raw_resource(_memento_resource)
      self.new(
        _memento_resource['method'],
        _memento_resource['url'],
        _memento_resource['sent_headers'] || {},
        _memento_resource['headers'],
        _memento_resource['data'],
        Base64.decode64(_memento_resource['content'])
      )
    end

    def uri
      @uri ||= Utils.parse_uri url
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
end