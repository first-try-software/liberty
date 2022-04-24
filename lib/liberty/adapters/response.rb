# frozen_string_literal: true

module Liberty
  module Adapters
    class Response
      CONTENT_TYPE = "Content-Type"
      CONTENT_LENGTH = "Content-Length"
      MIME_TYPE_JSON = "application/json"
      MIME_TYPE_HTML = "text/html"
      MIME_TYPE_TEXT = "text/plain"
      EMPTY_CONTENT = ""

      attr_reader :endpoint

      def initialize(endpoint)
        @endpoint = endpoint
      end

      def to_rack_response
        [status, headers, [content]]
      end

      private

      def status
        endpoint.status
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
        return MIME_TYPE_TEXT if text
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
