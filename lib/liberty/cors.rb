# frozen_string_literal: true

require_relative "cors/middleware"

module Liberty
  class CORS
    class << self
      def config
        yield(self)
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
