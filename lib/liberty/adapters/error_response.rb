# frozen_string_literal: true

module Liberty
  module Adapters
    class ErrorResponse
      attr_reader :endpoint

      def initialize(endpoint)
        @endpoint = endpoint
      end

      def to_rack_response
        [status, headers, rack_body]
      end

      private

      def headers
        {
          Response::CONTENT_LENGTH => body.bytesize.to_s,
          Response::CONTENT_TYPE => Response::MIME_TYPE_TEXT
        }
      end

      def rack_body
        endpoint.request.head? ? [] : [body]
      end
    end
  end
end
