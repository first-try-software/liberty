# frozen_string_literal: true

module Liberty
  class Endpoint
    DEFAULT_STATUS = 200

    def self.responds_to(verb, path)
      Liberty.add_endpoint(verb: verb, path: path, endpoint_class: self)
    end

    attr_reader :request, :principal

    def inject(request:, principal: nil)
      @request = request
      @principal = principal
    end

    def params
      request.params
    end

    def preferred_media_type
      request.headers[:preferred_media_type]
    end

    def authenticated?
      false
    end

    def www_authenticate_header
    end

    def authorized?
      false
    end

    def status
      DEFAULT_STATUS
    end

    def headers
    end

    def json
    end

    def html
    end

    def text
    end

    def body
    end
  end
end
