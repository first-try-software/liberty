# frozen_string_literal: true

require_relative "../authenticator"

module Liberty
  module Authenticators
    # The authenticator for open routes. It never finds a principal and never
    # challenges, so every request is admitted with a nil principal.
    class Public < Liberty::Authenticator
      def principal
        nil
      end

      def challenge_endpoint_class
        nil
      end
    end
  end
end
