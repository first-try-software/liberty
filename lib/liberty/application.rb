# frozen_string_literal: true

require_relative 'adapters/request'
require_relative 'adapters/response'

module Liberty
  class Application
    attr_reader :endpoint_class

    def initialize(endpoint_class:)
      @endpoint_class = endpoint_class
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
      endpoint_class.new.tap { |endpoint| endpoint.inject(request: request) }
    end
  end
end
