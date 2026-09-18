# frozen_string_literal: true

require_relative "errors"

module Liberty
  # The base authenticator. Liberty builds one per request, injects the
  # request, and asks two questions. Subclasses must answer both.
  #
  #   principal:
  #     who the request is from, or nil
  #
  #   challenge_endpoint_class:
  #     the endpoint class that answers when there is no principal, or nil
  #     to admit the request anyway
  #
  # The request is injected after construction, so a subclass is free to
  # define its own initializer with default dependencies.
  class Authenticator
    attr_reader :request

    def inject(request:)
      @request = request
    end

    def principal
      raise AbstractMethodError, "#{self.class} must implement #principal"
    end

    def challenge_endpoint_class
      raise AbstractMethodError, "#{self.class} must implement #challenge_endpoint_class"
    end
  end
end
