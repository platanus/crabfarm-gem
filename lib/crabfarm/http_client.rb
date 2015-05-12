require "uri"

module Crabfarm
  class HttpClient

    class HttpRequestError < StandardError
      extend Forwardable

      def_delegators :@response, :code, :body

      attr_reader :response

      def initialize(_response)
        @response = _response
        super _response.message
      end
    end

    class MaximumRedirectsError < StandardError
      def initialize
        super 'Redirection loop detected!'
      end
    end

    attr_reader :proxy_addr, :proxy_port

    def initialize(_proxy=nil)
      if Crabfarm.live?
        @proxy_addr = '127.0.0.1'
        @proxy_port = Crabfarm.live.proxy_port
      elsif _proxy.nil?
        @proxy_addr = nil
        @proxy_port = nil
      else
        @proxy_addr, @proxy_port = _proxy.split ':'
      end
    end

    def get(_url, _query={}, _headers={})
      uri = URI _url
      perform_request Net::HTTP::Get, uri, _headers
    end

    def post(_url, _data, _headers={})
      perform_request Net::HTTP::Post, URI(_url), _headers do |req|
        req.body = prepare_data(_data)
      end
    end

    def put(_url, _data, _headers={})
      perform_request Net::HTTP::Put, URI(_url), _headers do |req|
        req.body = prepare_data(_data)
      end
    end

    def delete(_url)
      perform_request Net::HTTP::Delete, URI(_url), _headers
    end

  private

    def perform_request(_req_type, _uri, _headers, _limit=10)

      raise MaximumRedirectsError.new if _limit == 0

      request = _req_type.new(_uri.request_uri.empty? ? '/' : _uri.request_uri)
      _headers.keys.each { |k| request[k] = _headers[k] }
      yield request if block_given?

      response = build_client(_uri).request request

      case response
      when Net::HTTPSuccess then
        response
      when Net::HTTPRedirection then
        location = response['location']
        perform_request(_req_type, URI.parse(location), _headers, _limit - 1)
      else
        handle_error_response response
      end
    end

    def build_client(uri)
      client = Net::HTTP.new uri.host, uri.port || 80, proxy_addr, proxy_port
      client.use_ssl = true if uri.scheme == 'https'
      client.verify_mode = OpenSSL::SSL::VERIFY_NONE
      client
    end

    def handle_error_response(_response)
      raise HttpRequestError.new _response
    end

    def prepare_data(_data)
      if _data.is_a? Hash
        _data.keys.map { |k| "#{k}=#{_data[k]}" }.join '&'
      else _data end
    end
  end
end