require 'pry'

module Crabfarm::Modes::Analizer
  class TraceService

    def initialize(_requests)
      @requests = _requests
    end

    def trace(_from, _stop_word)
      last_sources = [_from]
      sources = []

      while last_sources.length > 0
        sources = sources + last_sources

        last_sources = last_sources.inject([]) do |r, source|
          new_sources = []
          unless includes_user_word? source, _stop_word
            new_sources += trace_redirect source.uri.to_s if source.method == 'get'
            new_sources += trace_link source.uri if new_sources.length == 0
            # binding.pry
            new_sources += trace_cookies source.sent_headers['cookie'] if source.sent_headers['cookie']
          end
          r | new_sources
        end

        last_sources = last_sources - sources
      end

      sources
    end

  private

    def includes_user_word?(_request, _word)
      _request.uri.request_uri.include? _word or _request.request_data.include? _word
    end

    def trace_redirect(_url)
      redirect = @requests.find do |source|
        source.headers['location'] and source.headers['location'] == _url
      end

      redirect.nil? ? [] : [redirect]
    end

    def trace_link(_uri)
      strong_link = @requests.find do |source|
        next false unless /html/ === source.content_type
        next true if has_link_to? source, _uri
      end

      return [strong_link] unless strong_link.nil?

      # TODO: find weak references

      return []
    end

    def trace_cookies(_header)
      cookies = _header.split('; ')
      cookies.inject([]) do |r, cookie|
        r | @requests.select do |source|
          source.headers['set-cookie'] and source.headers['set-cookie'][0].include? cookie
        end
      end
    end

    def has_link_to?(_source, _uri)
      _source.response_data.scan(/(?:href|action|src)="([^"]+)"/).any? do |url|
        url = URI.join(_source.uri, url[0]) rescue nil
        next false if url.nil?

        url.fragment = nil # remove fragment
        url.to_s == _uri.to_s
      end
    end

  end
end