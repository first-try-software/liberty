# frozen_string_literal: true

require_relative "adapters/request"
require_relative "adapters/response"
require_relative "endpoint_builder"

module Liberty
  class Application
    attr_reader :endpoint_class, :authenticator_class

    def initialize(endpoint_class:, authenticator_class:)
      @endpoint_class = endpoint_class
      @authenticator_class = authenticator_class
    end

    def call(env)
      response(env).to_rack_response
    end

    private

    def response(env)
      Adapters::Response.new(endpoint(env))
    end

    def request(env)
      Adapters::Request.new(env)
    end

    def endpoint(env)
      EndpointBuilder.new(
        request: request(env),
        endpoint_class: endpoint_class,
        authenticator_class: authenticator_class
      ).endpoint
    end
  end
end
