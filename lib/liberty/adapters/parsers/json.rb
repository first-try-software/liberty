# frozen_string_literal: true

module Liberty
  module Adapters
    module Parsers
      class JSON
        def self.parse(text)
          text ? ::JSON.parse(text) : {}
        rescue ::JSON::ParserError
          {}
        end
      end
    end
  end
end
