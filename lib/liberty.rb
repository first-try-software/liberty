# frozen_string_literal: true

require "json"
require "mustermann"
require "rack"
require "rack/accept_media_types"
require "rack/abstract_format"

require_relative "liberty/version"
require_relative "liberty/endpoint"
require_relative "liberty/router"
require_relative "liberty/application"
require_relative "liberty/cors"

module Liberty
  def self.rack_app
    middleware
  end

  def self.middleware
    @middleware ||= Rack::Builder.new(Liberty.router) do
      use(Liberty::CORS::Middleware)
      use(Rack::AbstractFormat)
    end
  end

  def self.add_endpoint(verb:, path:, endpoint_class:)
    app = Application.new(endpoint_class: endpoint_class)
    router.public_send(verb, path, to: app)
  end

  def self.router
    @router ||= Liberty::Router.new
  end
end
