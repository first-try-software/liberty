# frozen_string_literal: true

require_relative "error_response"

module Liberty
  module Adapters
    class UnauthenticatedResponse < ErrorResponse
      WWW_AUTHENTICATE = "www-authenticate"

      private

      def status
        401
      end

      def headers
        challenge ? super.merge(WWW_AUTHENTICATE => challenge) : super
      end

      def challenge
        endpoint.www_authenticate_header
      end

      def body
        "Authentication required"
      end
    end
  end
end
