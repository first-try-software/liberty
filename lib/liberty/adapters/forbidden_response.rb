# frozen_string_literal: true

require_relative "error_response"

module Liberty
  module Adapters
    class ForbiddenResponse < ErrorResponse
      private

      def status
        403
      end

      def body
        "Forbidden"
      end
    end
  end
end
