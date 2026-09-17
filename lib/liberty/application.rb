# frozen_string_literal: true

require_relative "adapters/request"
require_relative "adapters/response"

module Liberty
  class Application
    attr_reader :endpoint_class, :authenticator

    def initialize(endpoint_class:, authenticator:)
      @endpoint_class = endpoint_class
      @authenticator = authenticator
    end

    def call(env)
      response(env).to_rack_response
    end

    private

    def response(env)
      Adapters::Response.new(endpoint(request(env)))
    end

    def request(env)
      Adapters::Request.new(env)
    end

    def endpoint(request)
      principal = authenticator.principal(request)
      build(endpoint_class_for(principal), request, principal)
    end

    def endpoint_class_for(principal)
      return endpoint_class if principal

      authenticator.challenge || endpoint_class
    end

    def build(klass, request, principal)
      klass.new.tap { |endpoint| endpoint.inject(request: request, principal: principal) }
    end
  end
end
