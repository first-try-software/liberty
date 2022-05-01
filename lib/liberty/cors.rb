# frozen_string_literal: true

require_relative "cors/middleware"

module Liberty
  class CORS
    ACCESS_CONTROL_HEADER = "Access-Control-Allow-Origin"

    class << self
      def config
        yield(self)
      end

      def configured?
        !@headers.nil? && !@headers.empty?
      end

      def access_control_header
        headers.slice(ACCESS_CONTROL_HEADER)
      end

      def headers
        @headers ||= {}
      end

      def headers=(headers)
        raise ArgumentError.new("Expected headers to be a Hash, received a #{headers.class} instead") unless headers.is_a?(Hash)

        @headers = headers
      end
    end
  end
end
