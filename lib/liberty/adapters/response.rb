# frozen_string_literal: true

require_relative "forbidden_response"
require_relative "unauthenticated_response"

module Liberty
  module Adapters
    class Response
      CONTENT_TYPE = "content-type"
      CONTENT_LENGTH = "content-length"
      MIME_TYPE_JSON = "application/json"
      MIME_TYPE_HTML = "text/html"
      MIME_TYPE_TEXT = "text/plain"
      EMPTY_CONTENT = ""

      attr_reader :endpoint

      def initialize(endpoint)
        @endpoint = endpoint
      end

      def to_rack_response
        return unauthenticated_response unless endpoint.authenticated?
        return forbidden_response unless endpoint.authorized?

        [status, headers, rack_body]
      end

      private

      def unauthenticated_response
        UnauthenticatedResponse.new(endpoint).to_rack_response
      end

      def forbidden_response
        ForbiddenResponse.new(endpoint).to_rack_response
      end

      def status
        endpoint.status
      end

      def rack_body
        head? ? [] : [content]
      end

      def head?
        endpoint.request.head?
      end

      def headers
        headers = {CONTENT_LENGTH => content_length}
        headers[CONTENT_TYPE] = content_type if content_type
        headers.merge!(response_headers)
        headers
      end

      def response_headers
        @response_headers ||= Hash(endpoint.headers)
      end

      def content_type
        return MIME_TYPE_JSON if json
        return MIME_TYPE_HTML if html
        MIME_TYPE_TEXT if text
      end

      def content_length
        content.bytesize.to_s
      end

      def content
        json || html || text || body || EMPTY_CONTENT
      end

      def json
        return unless response_json
        return stringified_json if valid_json?

        response_json.to_json
      end

      def response_json
        @response_json ||= endpoint.json
      end

      def html
        @html ||= endpoint.html
      end

      def text
        @text ||= endpoint.text
      end

      def body
        @body ||= endpoint.body
      end

      def valid_json?
        JSON.parse(stringified_json)
        true
      rescue JSON::ParserError
        false
      end

      def stringified_json
        @stringified_json ||= endpoint.json.to_s
      end
    end
  end
end
