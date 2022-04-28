# frozen_string_literal: true

module Liberty
  class CORS
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        return @app.call(env) unless cors_configured?
        return cors_response if cors_request?(env)

        with_cors_header(@app.call(env))
      end

      private

      def with_cors_header(response)
        status, headers, body = response

        [status, headers.merge(access_control_header), body]
      end

      def access_control_header
        Liberty::CORS.access_control_header
      end

      def cors_configured?
        Liberty::CORS.configured?
      end

      def cors_request?(env)
        env["REQUEST_METHOD"] == "OPTIONS"
      end

      def cors_response
        [200, default_headers.merge(Liberty::CORS.headers), []]
      end

      def default_headers
        {
          "Content-Type" => "text/plain",
          "Content-Length" => "0"
        }
      end
    end
  end
end
