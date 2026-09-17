# frozen_string_literal: true

module Liberty
  module Authenticators
    # The authenticator for open routes. It never finds a principal and never
    # challenges, so every request is admitted with a nil principal.
    #
    # Any object that answers these two questions can authenticate a route:
    #
    #   principal(request): who the request is from, or nil
    #   challenge: the endpoint class that answers when there is no
    #              principal, or nil to admit the request anyway
    class Public
      def self.principal(_request)
        nil
      end

      def self.challenge
        nil
      end
    end
  end
end
