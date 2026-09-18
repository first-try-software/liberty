# frozen_string_literal: true

module Liberty
  # The base for every error Liberty raises, so an application can rescue
  # them all with one clause.
  class Error < StandardError
  end

  # Raised when a subclass leaves a method unimplemented that Liberty
  # requires an answer to.
  class AbstractMethodError < Error
  end
end
