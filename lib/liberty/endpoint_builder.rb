# frozen_string_literal: true

module Liberty
  class EndpointBuilder
    attr_reader :request, :endpoint_class, :authenticator_class

    def initialize(request:, endpoint_class:, authenticator_class:)
      @request = request
      @endpoint_class = endpoint_class
      @authenticator_class = authenticator_class
    end

    def endpoint
      return build_challenge_endpoint if challenge?

      build_endpoint
    end

    private

    def build_challenge_endpoint
      challenge_endpoint_class.new.tap { |endpoint| inject_dependencies(endpoint) }
    end

    def build_endpoint
      endpoint_class.new.tap { |endpoint| inject_dependencies(endpoint) }
    end

    def principal
      @principal ||= authenticator.principal
    end

    def challenge_endpoint_class
      @challenge_endpoint_class ||= authenticator.challenge_endpoint_class
    end

    def challenge?
      principal.nil? && !challenge_endpoint_class.nil?
    end

    def authenticator
      @authenticator ||= authenticator_class.new.tap { |authenticator| authenticator.inject(request: request) }
    end

    def inject_dependencies(endpoint)
      endpoint.inject(request: request, principal: principal)
    end
  end
end
